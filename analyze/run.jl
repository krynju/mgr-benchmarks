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

sort!(d, :time)
d = combine(groupby(d, [:tech, :type, :chunksize, :n, :unique_vals]), first)
g = groupby(d, [:type, :chunksize, :unique_vals])

benchmarks = combine(d, :type => unique)


@sprintf("%.3E", 1E10)

function process_group(group)
    techs = groupby(group, :tech)
    type = first(group[!, :type])
    p = plot(
        title=type,
        xscale=:log10,
        yscale=:log10,
    )
    for t in techs
        _t = sort(t, :n)
        x = _t.n
        y = _t.time
        plot!(p, x, y, label=first(t.tech))
    end
    display(p)
end

for gg in g
    process_group(gg)
end
