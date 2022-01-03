DISPLAY_PLOTS = true
SAVE_PLOTS = false
SAVE_PDF = false
SAVEDIR = "plots_dtable_grouped"

using Printf, Plots
include("load_data.jl")

d = load_data()
sort!(d, [:n, :time])
d = combine(groupby(d, [:tech, :type, :chunksize, :n, :unique_vals, :workers, :threads]), first)
d = d[d.tech.=="dtable", :]
sort!(d, :n)
mkpath(SAVEDIR)


function inner_loop(p, gg, ops)
    plot!(p;
        xscale = :log10,
        yscale = :log10,
        common_style_kwargs...
    )
    for (i, k) in enumerate(ops)
        g = groupby(gg, :type)[(type = k,)]
        config = groupby(g, [:workers, :threads])
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )
        for kk in envsetupsorder
            (workers = kk[1], threads = kk[2]) ∉ keys(config) && continue
            t = config[(workers = kk[1], threads = kk[2])]
            tech = first(t)
            x = t.n
            y = t.time / 1e9
            plot!(
                p, x, y,
                label = envsetupmapping[kk],
                # marker = :star,
                # markercolor = color_mapping[tech],
                linecolor = envsetupcolormapping[kk],
                subplot = i
            )
        end
    end
    plot!(p, legend = :none)
    plot!(p, subplot = 1, legend = :topleft)
    plot!(p, xlabel="", ylabel="")
    for i in [1,1+size(p.layout.grid)[2]]
        plot!(p, subplot=i, ylabel=common_style_kwargs[5])
    end
    for i in (1+size(p.layout.grid)[2]):(size(p.layout.grid)[2]*size(p.layout.grid)[1])
        plot!(p, subplot=i, xlabel=common_style_kwargs[4])
    end
    p
end


dd = d[d.type.∈Ref(basic_ops), :]
type_mapping = basic_type_mapping
for gg in groupby(dd, [:chunksize, :unique_vals])
    f = first(gg)
    title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(layout = length(basic_ops))
    p = inner_loop(p, gg, basic_ops)
    plot!(p; plot_title = title, leftoverfontsizes...)
    DISPLAY_PLOTS && display(p)
    SAVE_PLOTS && savefig(p, SAVEDIR * "/basic_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
    SAVE_PDF && savefig(p, SAVEDIR * "/basic_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
end


dd = d[d.type.∈Ref(advanced_ops), :]
type_mapping = advanced_type_mapping
for gg in groupby(dd, [:chunksize, :unique_vals])
    f = first(gg)
    title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(layout = length(advanced_ops),)
    p = inner_loop(p, gg, advanced_ops)
    plot!(p; plot_title = title, leftoverfontsizes...)
    DISPLAY_PLOTS && display(p)
    SAVE_PDF && savefig(p, SAVEDIR * "/advanced_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
    SAVE_PLOTS && savefig(p, SAVEDIR * "/advanced_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end



dd = d[d.type.∈Ref(scenario_ops), :]
type_mapping = scenario_type_mapping
for gg in groupby(dd, [:chunksize, :unique_vals])
    f = first(gg)
    title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(layout = length(scenario_ops) + 1,)
    p = inner_loop(p, gg, scenario_ops)
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
    plot!(p; plot_title = title, leftoverfontsizes...)
    DISPLAY_PLOTS && display(p)
    SAVE_PDF && savefig(p, SAVEDIR * "/scenario_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
    SAVE_PLOTS && savefig(p, SAVEDIR * "/scenario_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end
