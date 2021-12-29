DISPLAY_PLOTS = false
SAVE_PLOTS = true
SAVEDIR = "plots"

using Printf, Plots
include("load_data.jl")

d = load_data()

sort!(d, [:n, :time])
d = combine(groupby(d, [:tech, :type, :chunksize, :n, :unique_vals, :workers, :threads]), first)
g = groupby(d, [:type, :chunksize, :unique_vals, :workers, :threads])

benchmarks = combine(d, :type => unique)

# rm("plots", force=true, recursive=true)
mkpath(SAVEDIR)

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
        y = t.time / 1e9 / 60
        plot!(
            p, x, y,
            label=tech,
            linecolor=color_mapping[tech]
        )
    end
    DISPLAY_PLOTS && display(p)
    SAVE_PLOTS && savefig(p, SAVEDIR * "/w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))_$(f.type).png")
end

for gg in g
    process_group(gg)
end
