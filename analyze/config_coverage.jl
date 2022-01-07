using Printf
include("load_data.jl")

d = load_data()

g = groupby(d, [:threads, :workers, :type, :n, :chunksize, :unique_vals])
c = combine(g,
    :tech => (x -> "dtable" in x) => :dtable,
    :tech => (x -> "dask" in x) => :dask,
    :tech => (x -> "spark" in x) => :spark,
)
configs = []

type = ["increment_map", "filter_half", "reduce_var_all", "reduce_var_single", "groupby_single_col", "grouped_reduce_mean_singlecol",
    "grouped_reduce_mean_allcols", "innerjoin_r_unique", "scenario_table_load", "scenario_full_table_statistics", "scenario_count_unique_a1", "scenario_rowwise_sum_and_mean_reduce", "scenario_grouped_a1_statistics"]

basic_types = [
    "increment_map", "filter_half", "reduce_var_all",
    "reduce_var_single"]

function loopy()
    for w in workers
        for t in threads
            for n in ns
                for ch in chunksizes
                    for uvc in unique_vals
                        push!(configs, (workers = w, threads = t, n = n, chunksize = ch, unique_vals = uvc))
                    end
                end
            end
        end
    end
end


threads = [2, 4, 8, 16]
workers = [1]
ns = Int[1e7, 1e8, 5e8, 1e9]
chunksizes = Int[1e7, 2.5e7]
unique_vals = Int[1e3, 1e4]
loopy()
threads = [4]
workers = [4, 8]
ns = Int[1e7, 1e8, 5e8, 1e9, 2e9]
chunksizes = Int[1e7]
unique_vals = Int[1e3]
loopy()

threads = [4]
workers = [4, 8]
ns = Int[1e7, 1e8, 5e8, 1e9, 2e9]
chunksizes = Int[1e7]
unique_vals = Int[1e4]
    
loopy()
configs

d2 = DataFrame(configs)
d3 = crossjoin(d2, DataFrame(type = type))
d3 = d3[.!((d3.type .∈ Ref(basic_types)) .& (d3.unique_vals .== 10000)), :]

d4 = leftjoin(d3, select(d[d.tech.=="dtable", :], :threads, :workers, :type, :n, :chunksize, :unique_vals, :time => :time_dtable), on = [:threads, :workers, :type, :n, :chunksize, :unique_vals])
d4 = leftjoin(d4, select(d[d.tech.=="dask", :], :threads, :workers, :type, :n, :chunksize, :unique_vals, :time => :time_dask), on = [:threads, :workers, :type, :n, :chunksize, :unique_vals])
d4 = leftjoin(d4, select(d[d.tech.=="spark", :], :threads, :workers, :type, :n, :chunksize, :unique_vals, :time => :time_spark), on = [:threads, :workers, :type, :n, :chunksize, :unique_vals])
d4[d4.workers .== 1, :time_spark] .= -1
# d4[(d4.n .== Int(2e9)).&(d4.unique_vals .== 10000).&(startswith.(d4.type, Ref("group"))),:time_dtable] .= -1
d4[(d4.workers.!=1).&(d4.type.=="innerjoin_r_unique").&(d4.n .== Int(2e9)), :time_dask] .= -1

coverage = combine(d4, [:time_dtable, :time_dask, :time_spark] => ByRow((x, y, z) -> !ismissing(x) + !ismissing(y) + !ismissing(z)))
coverage_p = combine(coverage, 1 => sum)[1, 1] / 3 / nrow(d4) * 100
done = combine(coverage, 1 => sum)[1, 1] 
println("$coverage_p % of benchmark coverage")
println("$done done out of $(nrow(d4)*3)")
dtable_threaded = combine(combine(d4[d4.workers .== 1,:], :time_dtable => ByRow((x)->!ismissing(x))), 1=>sum)[1,1]
println("$dtable_threaded dtable threaded done out of $(nrow(d4[d4.workers .== 1,:]))")
dask_threaded = combine(combine(d4[d4.workers .== 1,:], :time_dask => ByRow((x)->!ismissing(x))), 1=>sum)[1,1]
println("$dask_threaded dask threaded done out of $(nrow(d4[d4.workers .== 1,:]))")

coverage_gcp = combine(d4[d4.workers .!= 1,:], [:time_dtable, :time_dask, :time_spark] => ByRow((x, y, z) -> !ismissing(x) + !ismissing(y) + !ismissing(z)))
coverage_gcp_p = combine(coverage_gcp, 1 => sum)[1, 1] / 3 / nrow(d4[d4.workers.!=1,:]) * 100