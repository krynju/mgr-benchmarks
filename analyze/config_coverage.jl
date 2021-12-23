using CSV, DataFrames, Printf, Plots

wdirs = ["dask", "dtable", "spark"]

function get_result_files(wdir)
    a = readdir(wdir, join=true)
    r_only = filter(x-> occursin("result", x), a)
    vcat(readdir.(r_only, join=true)...)
end

result_files = vcat(get_result_files.(wdirs)...)
d = CSV.read(result_files, DataFrame)
dropmissing!(d)
d = d[d.chunksize .!= 1_000_000, :]
d = d[d.n .!= 1_000_000, :]
d = d[d.type .!= "count", :]
d = d[d.type .!= "scenario_full_run", :]
d = d[d.workers .!= 2, :]

g = groupby(d, [:threads, :workers ,:type, :n, :chunksize, :unique_vals])
c = combine(g,
    :tech => (x -> "dtable" in x) => :dtable,
    :tech => (x -> "dask" in x) => :dask,
    :tech => (x -> "spark" in x) => :spark,
)
d = combine(groupby(d, [:threads, :workers ,:type, :n, :chunksize, :unique_vals, :tech]), :time=>minimum=>:time)
configs=[]

type = ["increment_map", "filter_half", "reduce_var_all", "reduce_var_single", "groupby_single_col", "grouped_reduce_mean_singlecol", 
"grouped_reduce_mean_allcols", "innerjoin_r_unique", "scenario_table_load", "scenario_full_table_statistics", "scenario_count_unique_a1", "scenario_rowwise_sum_and_mean_reduce", "scenario_grouped_a1_statistics"]

function loopy()
    for w in workers
        for t in threads
            for n in ns
                for ch in chunksizes
                    for uvc in unique_vals
                        push!(configs,(workers=w, threads=t, n=n, chunksize=ch, unique_vals=uvc))
                    end
                end
            end
        end
    end
end


threads = [8, 16]
workers = [1]
ns = Int[1e7, 1e8, 5e8, 1e9]
chunksizes = Int[1e7, 2.5e7]
unique_vals = Int[1e3, 1e4]
loopy()
threads = [4]
workers = [4, 8 ,12]
ns = Int[1e7, 1e8, 5e8, 1e9, 2e9, 3e9]
chunksizes = Int[1e7, 2.5e7]
unique_vals = Int[1e3]
loopy()

threads = [4]
workers = [4, 8 ,12]
ns = Int[1e7, 1e8, 5e8, 1e9, 2e9]
chunksizes = Int[1e7, 2.5e7]
unique_vals = Int[1e4]

loopy()
configs

d2 = DataFrame(configs)
d3 = crossjoin(d2, DataFrame(type=type))

d4 = leftjoin(d3, select(d[d.tech .== "dtable", :], :threads, :workers ,:type, :n, :chunksize, :unique_vals, :time => :time_dtable), on=[:threads, :workers ,:type, :n, :chunksize, :unique_vals])
d4 = leftjoin(d4, select(d[d.tech .== "dask", :], :threads, :workers ,:type, :n, :chunksize, :unique_vals, :time => :time_dask), on=[:threads, :workers ,:type, :n, :chunksize, :unique_vals])
d4 = leftjoin(d4, select(d[d.tech .== "spark", :], :threads, :workers ,:type, :n, :chunksize, :unique_vals, :time => :time_spark), on=[:threads, :workers ,:type, :n, :chunksize, :unique_vals])


coverage = combine(d4, [:time_dtable, :time_dask, :time_spark] => ByRow((x,y,z) -> !ismissing(x) + !ismissing(y) + !ismissing(z)))
coverage = combine(coverage, 1=> sum)[1, 1] /3 / nrow(d4) * 100

