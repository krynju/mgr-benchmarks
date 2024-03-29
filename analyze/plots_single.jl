DISPLAY_PLOTS = false
SAVE_PLOTS = true
SAVE_PDF = true
SAVEDIR = "plots/plots_single/"

using Printf, Plots
include("load_data.jl")

d = load_data()
sort!(d, [:n, :time])
g = groupby(d, [:type, :chunksize, :unique_vals, :workers, :threads])

benchmarks = combine(d, :type => unique)

# rm("plots", force=true, recursive=true)
mkpath(SAVEDIR)

function filename(f)
    "w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))_$(f.type)"
end

function process_group(group)
    techs = groupby(group, :tech)
    f = first(group[!, :])

    title = "$(f.type)\nw=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        xscale = :log10,
        yscale = :log10,
        legend = :topleft
    )
    plot!(p; common_style_kwargs...)
    for t in techs
        tech = first(t.tech)
        x = t.n
        y = t.time
        plot!(
            p, x, y,
            label = tech,
            marker = :star,
            markercolor = color_mapping[tech],
            linecolor = color_mapping[tech]
        )
    end
    plot!(p, plot_title = title, plot_titlefontsize = 10)
    saveplot(p, SAVEDIR,  filename(f))
end

for gg in g
    process_group(gg)
end
