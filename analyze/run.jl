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
d = d[d.chunksize .!= 1000_000, :]
d = d[d.n .!= 1_000_000, :]
d = d[d.type .!= "count", :]


sort!(d, [:n, :time])
d = combine(groupby(d, [:tech, :type, :chunksize, :n, :unique_vals]), first)
g = groupby(d, [:type, :chunksize, :unique_vals, :workers, :threads])

benchmarks = combine(d, :type => unique)

rm("plots", force=true, recursive=true)
mkpath("plots")

color_palette = palette(:tab10)
color_mapping = Dict(
    "dtable" => color_palette[3],
    "dask" => color_palette[1],
    "spark" => color_palette[2]
)


function process_group(group)
    techs = groupby(group, :tech)
    f = first(group[!, :])

    title = "$(f.type)\nw=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        title=title,
        xscale=:log10,
        yscale=:log10,
        legend=:topleft
    )
    for t in techs
        tech = first(t.tech)
        x = t.n
        y = t.time
        plot!(
            p, x, y,
            label=tech,
            linecolor=color_mapping[tech]
        )
    end
    display(p)
    savefig(p, "plots/$(f.type)_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end

for gg in g
    process_group(gg)
end
