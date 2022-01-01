DISPLAY_PLOTS = true
SAVE_PLOTS = true
SAVEDIR = "plots2"

using Printf, Plots
include("load_data.jl")

d = load_data()
sort!(d, [:n, :time])
d = combine(groupby(d, [:tech, :type, :chunksize, :n, :unique_vals, :workers, :threads]), first)
sort!(d, :n)
mkpath(SAVEDIR)

dd = d[d.type.∈Ref(basic_ops), :]
type_mapping = basic_type_mapping
for gg in groupby(dd, [:chunksize, :unique_vals, :workers, :threads])
    f = first(gg)
    title = "w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        layout = length(basic_ops),
    )
    plot!(p; common_style_kwargs...)

    for (i, k) in enumerate(basic_ops)
        g = groupby(gg, :type)[(type = k,)]
        techs = groupby(g, :tech)
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )
        for t in techs
            tech = first(t.tech)
            x = t.n
            y = t.time / 1e9
            plot!(
                p, x, y,
                label = tech,
                marker = :star,
                markercolor = color_mapping[tech],
                linecolor = color_mapping[tech],
                subplot = i
            )
        end
    end
    plot!(p, legend = :none)
    plot!(p, subplot = 1, legend = :topleft)
    plot!(p, plot_title = title, plot_titlefontsize = 10)
    DISPLAY_PLOTS && display(p)
    @async SAVE_PLOTS && savefig(p, SAVEDIR * "/basic_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end



dd = d[d.type.∈Ref(advanced_ops), :]
type_mapping = advanced_type_mapping
for gg in groupby(dd, [:chunksize, :unique_vals, :workers, :threads])
    f = first(gg)
    title = "w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        xscale = :log10,
        yscale = :log10,
        layout = length(advanced_ops),
    )
    plot!(p; common_style_kwargs...)
    for (i, k) in enumerate(advanced_ops)
        g = groupby(gg, :type)[(type = k,)]
        techs = groupby(g, :tech)
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )
        for t in techs
            tech = first(t.tech)
            x = t.n
            y = t.time ./ 1e9
            plot!(
                p, x, y,
                label = tech,
                marker = :star,
                markercolor = color_mapping[tech],
                linecolor = color_mapping[tech],
                subplot = i
            )
        end
    end
    plot!(p, legend = :none)
    plot!(p, subplot = 1, legend = :topleft)
    plot!(p, plot_title = title, plot_titlefontsize = 10)
    DISPLAY_PLOTS && display(p)
    @async SAVE_PLOTS && savefig(p, SAVEDIR * "/advanced_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end



dd = d[d.type.∈Ref(scenario_ops), :]
type_mapping = scenario_type_mapping
for gg in groupby(dd, [:chunksize, :unique_vals, :workers, :threads])
    f = first(gg)
    title = "w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        xscale = :log10,
        yscale = :log10,
        layout = length(scenario_ops) + 1,
    )
    plot!(p; common_style_kwargs...)
    for (i, k) in enumerate(scenario_ops)
        (type = k, ) ∉ keys(groupby(gg, :type)) && continue
        g = groupby(gg, :type)[(type = k,)]
        techs = groupby(g, :tech)
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )
        for t in techs
            tech = first(t.tech)
            x = t.n
            y = t.time ./ 1e9
            plot!(
                p, x, y,
                marker = :star,
                markercolor = color_mapping[tech],
                label = tech,
                linecolor = color_mapping[tech],
                subplot = i
            )
        end
    end
    techs = groupby(gg, :tech)
    plot!(
        p,
        subplot = 6,
        title = "total",
    )
    for t in techs
        c = combine(groupby(t, :n), :time => sum)
        tech = first(t.tech)
        x = c.n
        y = c.time_sum ./ 1e9
        plot!(
            p, x, y,
            label = tech,
            marker = :star,
            markercolor = color_mapping[tech],
            linecolor = color_mapping[tech],
            subplot = 6
        )
    end
    plot!(p, legend = :none)
    plot!(p, subplot = 1, legend = :topleft)
    plot!(p, plot_title = title, plot_titlefontsize = 10)
    DISPLAY_PLOTS && display(p)
    SAVE_PLOTS && savefig(p, SAVEDIR * "/scenario_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end
