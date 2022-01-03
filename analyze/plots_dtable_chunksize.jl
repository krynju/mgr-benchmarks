DISPLAY_PLOTS = true
SAVE_PLOTS = true
SAVE_PDF = false
SAVEDIR = "plots/plots_dtable_chunksize"

using Printf, Plots
include("load_data.jl")

_d = load_data()
sort!(_d, [:n, :time])
_d = combine(groupby(_d, [:tech, :type, :chunksize, :n, :unique_vals, :workers, :threads]), first)
_d = _d[_d.tech.=="dtable", :]
sort!(_d, :n)
mkpath(SAVEDIR)


using LaTeXStrings

groupbycols = [:workers, :threads, :unique_vals]
chunksizes = Int[1e7, 2.5e7]


function inner_loop(p, gg, ops, type_mapping)
    plot!(p;
        xscale = :log10,
        yscale = :log10,
        common_style_kwargs...
    )
    for (i, k) in enumerate(ops)
        g = groupby(gg, :type)[(type = k,)]
        config = groupby(g, [:chunksize])
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )
        for kk in chunksizes
            (chunksize=kk,) ∉ keys(config) && continue
            t = config[(chunksize=kk,)]
            tech = first(t)
            x = t.n
            y = t.time / 1e9
            plot!(
                p, x, y,
                label = "$kk",
                # marker = :star,
                # markercolor = color_mapping[tech],
                # linecolor = envsetupcolormapping[kk],
                subplot = i,
                # xticks=(x, [L"%10^{%$(floor(Int, log10(a)))}" for a in x])
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

for (prefix, d) in [
    # ("all", _d),
    # ("wor", _d[_d.workers .!= 1, :]),
    ("thr", _d[_d.workers .== 1, :]),
]
    dd = d[d.type.∈Ref(basic_ops), :]
    for gg in groupby(dd, groupbycols)
        f = first(gg)
        title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
        p = plot(layout = length(basic_ops))
        p = inner_loop(p, gg, basic_ops, basic_type_mapping)
        plot!(p; plot_title = title, leftoverfontsizes...)
        DISPLAY_PLOTS && display(p)
        SAVE_PLOTS && savefig(p, SAVEDIR * "/$(prefix)_basic_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
        SAVE_PDF && savefig(p, SAVEDIR * "/$(prefix)_basic_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
    end

    dd = d[d.type.∈Ref(advanced_ops), :]

    for gg in groupby(dd, groupbycols)
        f = first(gg)
        title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
        p = plot(layout = length(advanced_ops),)
        p = inner_loop(p, gg, advanced_ops,advanced_type_mapping)
        plot!(p; plot_title = title, leftoverfontsizes...)
        DISPLAY_PLOTS && display(p)
        SAVE_PDF && savefig(p, SAVEDIR * "/$(prefix)_advanced_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
        SAVE_PLOTS && savefig(p, SAVEDIR * "/$(prefix)_advanced_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
    end


    dd = d[d.type.∈Ref(scenario_ops), :]
    for gg in groupby(dd, groupbycols)
        f = first(gg)
        title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
        p = plot(layout = length(scenario_ops) + 1,)
        p = inner_loop(p, gg, scenario_ops, scenario_type_mapping)
        techs = groupby(gg, :chunksize)
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
        SAVE_PDF && savefig(p, SAVEDIR * "/$(prefix)_scenario_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).pdf")
        SAVE_PLOTS && savefig(p, SAVEDIR * "/$(prefix)_scenario_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
    end
end
