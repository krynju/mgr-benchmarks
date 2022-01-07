DISPLAY_PLOTS = false
SAVE_PLOTS = true
SAVE_PDF = true
SAVEDIR = "plots/plots_by_type"

using Printf, Plots
include("load_data.jl")

d = load_data()
sort!(d, [:n, :time])
mkpath(SAVEDIR)

function inner_loop(p, gg, ops)
    plot!(p;common_style_kwargs...)
    plot!(p;common_style_kwargs2...)

    for (i, k) in enumerate(ops)
        g = groupby(gg, :type)[(type = k,)]
        techs = groupby(g, :tech)
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = OPS_NAME_MAPPING[fg.type],
        )
        for _t in techs_list
            groupingkey = (tech = _t,)
            groupingkey ∉ keys(techs) && continue
            t = techs[groupingkey]
            tech = first(t.tech)
            x = t.n
            y = t.time
            plot!(
                p, x, y,
                label = techs_name_mapping[tech],
                marker = techs_marker_mapping[tech],
                markercolor = color_mapping[tech],
                linecolor = color_mapping[tech],
                subplot = i,
                xticks = (x, xtickslabels),
                ; markerargs...
            )
        end
    end
    p=populate_labels(p)
    p
end

dd = d[d.type.∈Ref(basic_ops), :]

for gg in groupby(dd, [:chunksize, :unique_vals, :workers, :threads])
    f = first(gg)
    title = "w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(layout = length(basic_ops))
    p = inner_loop(p, gg, basic_ops)
    p = epi(p, title)
    DISPLAY_PLOTS && display(p)
    SAVE_PDF && savefig(p, SAVEDIR * "/basic_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
    SAVE_PLOTS && savefig(p, SAVEDIR * "/basic_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end



dd = d[d.type.∈Ref(advanced_ops), :]

for gg in groupby(dd, [:chunksize, :unique_vals, :workers, :threads])
    f = first(gg)
    title = "w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(layout = length(advanced_ops))
    p = inner_loop(p, gg, advanced_ops)
    p = epi(p, title)
    DISPLAY_PLOTS && display(p)
    SAVE_PDF && savefig(p, SAVEDIR * "/advanced_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
    SAVE_PLOTS && savefig(p, SAVEDIR * "/advanced_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end



dd = d[d.type.∈Ref(scenario_ops), :]
for gg in groupby(dd, [:chunksize, :unique_vals, :workers, :threads])
    f = first(gg)
    title = "w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(layout = length(scenario_ops) + 1)
    p = inner_loop(p, gg, scenario_ops)
    techs = groupby(gg, :tech)
    plot!(
        p,
        subplot = 6,
        title = OPS_NAME_MAPPING["total"],
    )
    for t in techs
        ccc = combine(groupby(t, :n), :time => sum)
        tech = first(t.tech)
        x = ccc.n
        y = ccc.time_sum
        plot!(
            p, x, y,
            label = tech,
            marker = techs_marker_mapping[tech],
            markercolor = color_mapping[tech],
            linecolor = color_mapping[tech],
            subplot = 6,
            xticks = (x, xtickslabels)
            ; markerargs...
        )
    end
    p = epi(p, title)
    DISPLAY_PLOTS && display(p)
    SAVE_PDF && savefig(p, SAVEDIR * "/scenario_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
    SAVE_PLOTS && savefig(p, SAVEDIR * "/scenario_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end
