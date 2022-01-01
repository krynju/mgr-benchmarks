DISPLAY_PLOTS = true
SAVE_PLOTS = true
SAVE_PDF = true
SAVEDIR = "plots3"

using Printf, Plots
include("load_data.jl")

d = load_data()
sort!(d, [:n, :time])
d = combine(groupby(d, [:tech, :type, :chunksize, :n, :unique_vals, :workers, :threads]), first)
sort!(d, :n)
mkpath(SAVEDIR)

d = d[d.tech .== "dtable", :]


dd = d[d.type.∈Ref(basic_ops), :]
type_mapping=basic_type_mapping
for gg in groupby(dd, [:chunksize, :unique_vals])
    f = first(gg)
    title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        xscale = :log10,
        yscale = :log10,
        layout = length(basic_ops),
    )
    plot!(p; common_style_kwargs...)

    for (i, k) in enumerate(basic_ops)
        g = groupby(gg, :type)[(type = k,)]
        config = groupby(g, [:workers, :threads])
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )
        for t in config
            tech = first(t)
            x = t.n
            y = t.time / 1e9
            plot!(
                p, x, y,
                label = "$(tech.workers), $(tech.threads)",
                # marker = :star,
                # markercolor = color_mapping[tech],
                # linecolor = color_mapping[tech],
                subplot = i
            )
        end
    end
    plot!(p, legend = :none)
    plot!(p, subplot = 1, legend = :topleft)
    plot!(p, plot_title=title, plot_titlefontsize=10)
    DISPLAY_PLOTS && display(p)
    @async SAVE_PLOTS && savefig(p, SAVEDIR * "/basic_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end



dd = d[d.type.∈Ref(advanced_ops), :]
type_mapping=advanced_type_mapping
for gg in groupby(dd, [:chunksize, :unique_vals])
    f = first(gg)
    title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        xscale = :log10,
        yscale = :log10,
        layout = length(advanced_ops),
    )
    plot!(p; common_style_kwargs...)

    for (i, k) in enumerate(advanced_ops)
        g = groupby(gg, :type)[(type = k,)]
        config = groupby(g, [:workers, :threads])
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )
        for t in config
            tech = first(t)
            x = t.n
            y = t.time / 1e9
            plot!(
                p, x, y,
                label = "$(tech.workers), $(tech.threads)",
                # marker = :star,
                # markercolor = color_mapping[tech],
                # linecolor = color_mapping[tech],
                subplot = i
            )
        end
    end
    plot!(p, legend = :none)
    plot!(p, subplot = 1, legend = :topleft)
    plot!(p, plot_title=title, plot_titlefontsize=10)
    DISPLAY_PLOTS && display(p)
    @async SAVE_PLOTS && savefig(p, SAVEDIR * "/advanced_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end



dd = d[d.type.∈Ref(scenario_ops), :]
type_mapping=scenario_type_mapping
for gg in groupby(dd, [:chunksize, :unique_vals])
    f = first(gg)
    title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        xscale = :log10,
        yscale = :log10,
        layout = length(scenario_ops)+1,
    )
    plot!(p; common_style_kwargs...)

    for (i, k) in enumerate(scenario_ops)
        g = groupby(gg, :type)[(type = k,)]
        config = groupby(g, [:workers, :threads])
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )
        for t in config
            tech = first(t)
            x = t.n
            y = t.time / 1e9
            plot!(
                p, x, y,
                label = "$(tech.workers), $(tech.threads)",
                # marker = :star,
                # markercolor = color_mapping[tech],
                # linecolor = color_mapping[tech],
                subplot = i
            )
        end
    end
    techs = groupby(gg, [:workers, :threads])
    plot!(
        p,
        subplot = 6,
        title = "total",
    )
    for t in techs
        c = combine(groupby(t, :n), :time => sum)
        tech = first(t)
        x = c.n
        y = c.time_sum ./ 1e9
        plot!(
            p, x, y,
            label = "$(tech.workers), $(tech.threads)",
            # linecolor = color_mapping[tech],
            subplot = 6
        )
    end
    plot!(p, legend = :none)
    plot!(p, subplot = 1, legend = :topleft)
    plot!(p, plot_title=title, plot_titlefontsize=10)
    DISPLAY_PLOTS && display(p)
    SAVE_PDF && savefig(p, SAVEDIR * "/scenario_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
    SAVE_PLOTS && savefig(p, SAVEDIR * "/scenario_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end
