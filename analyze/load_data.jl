using CSV, DataFrames
include("common.jl")

function load_data()
    wdirs = ["./"]

    function get_result_files(wdir)
        a = readdir(wdir, join=true)
        r_only = filter(x-> occursin("result", x), a)
        vcat(readdir.(r_only, join=true)...)
    end

    result_files = vcat(get_result_files.(wdirs)...)
    d = CSV.read(result_files, DataFrame, pool=false)
    dropmissing!(d)
    d = d[d.chunksize .!= 1_000_000, :]
    d = d[d.n .!= 1_000_000, :]
    d = d[d.type .!= "count", :]
    d = d[d.type .!= "scenario_full_run", :]
    d = d[d.workers .!= 2, :]
    d = d[.!((d.workers .== 4).&(d.chunksize .== 25000000)), :]
    d = d[.!((d.type .∈ Ref(basic_types)).&(d.unique_vals .== 10000)),: ]
end
