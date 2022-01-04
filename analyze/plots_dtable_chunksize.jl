DISPLAY_PLOTS = false
SAVE_PLOTS = true
SAVE_PDF = true
SAVEDIR = "plots/plots_dtable_chunksize/"

using Printf, Plots
include("load_data.jl")

_d = load_data()
sort!(_d, [:n, :time])
_d = combine(groupby(_d, [:tech, :type, :chunksize, :n, :unique_vals, :workers, :threads]), first)
# _d = _d[_d.tech.=="dtable", :]
sort!(_d, :n)
mkpath(SAVEDIR)


using LaTeXStrings

function filename(group, prefix, f)
    "$(prefix)_$(group)_w=$(f.workers),t=$(f.threads),u=$(@sprintf("%.1E", f.unique_vals))"
end


groupbycols = [:workers, :threads, :unique_vals]
innergroupbycols = [:tech, :chunksize]
chunksizes = Int[1e7, 2.5e7]
chunksizes_colors = Dict(
    Int(1e7) => color_palette[1],
    Int(2.5e7) => color_palette[2],
)


function inner_loop(p, gg, ops, type_mapping)
    plot!(p;
        xscale = :log10,
        yscale = :log10,
        common_style_kwargs...
    )
    for (i, k) in enumerate(ops)
        g = groupby(gg, :type)[(type = k,)]
        config = groupby(g, innergroupbycols)
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )

        for (tech, kk) in [(ttt, kkk) for ttt in techs_list for kkk in chunksizes]
            groupkey = (tech = tech, chunksize = kk,)
            groupkey ∉ keys(config) && continue
            t = config[groupkey]
            x = t.n
            y = t.time
            plot!(
                p, x, y,
                label = "$tech $kk",
                # marker = :star,
                # markercolor = color_mapping[tech],
                # linecolor = chunksizes_colors[kk],
                subplot = i,
                # xticks=(x, [L"%10^{%$(floor(Int, log10(a)))}" for a in x])
            )
        end
    end
    plot!(p, legend = :none)
    plot!(p, subplot = 1, legend = :topleft)
    plot!(p, xlabel = "", ylabel = "")
    for i in [1, 1 + size(p.layout.grid)[2]]
        plot!(p, subplot = i, ylabel = common_style_kwargs[5])
    end
    for i in (1+size(p.layout.grid)[2]):(size(p.layout.grid)[2]*size(p.layout.grid)[1])
        plot!(p, subplot = i, xlabel = common_style_kwargs[4])
    end
    p
end

for (prefix, d) in [
    # ("all", _d),
    # ("wor", _d[_d.workers .!= 1, :]),
    ("thr", _d[_d.workers.==1, :]),
]
    dd = d[d.type.∈Ref(basic_ops), :]
    for gg in groupby(dd, groupbycols)
        f = first(gg)
        title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
        p = plot(layout = length(basic_ops))
        p = inner_loop(p, gg, basic_ops, basic_type_mapping)
        plot!(p; plot_title = title, leftoverfontsizes...)
        DISPLAY_PLOTS && display(p)
        SAVE_PLOTS && savefig(p, SAVEDIR * filename("basic", prefix, f) * ".png")
        SAVE_PDF && savefig(p, SAVEDIR * filename("basic", prefix, f) * ".pdf")
    end

    dd = d[d.type.∈Ref(advanced_ops), :]

    for gg in groupby(dd, groupbycols)
        f = first(gg)
        title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
        p = plot(layout = length(advanced_ops),)
        p = inner_loop(p, gg, advanced_ops, advanced_type_mapping)
        plot!(p; plot_title = title, leftoverfontsizes...)
        DISPLAY_PLOTS && display(p)
        SAVE_PDF && savefig(p, SAVEDIR * filename("advanced", prefix, f) * ".pdf")
        SAVE_PLOTS && savefig(p, SAVEDIR * filename("advanced", prefix, f) * ".png")
    end


    dd = d[d.type.∈Ref(scenario_ops), :]
    for gg in groupby(dd, groupbycols)
        f = first(gg)
        title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
        p = plot(layout = length(scenario_ops) + 1,)
        p = inner_loop(p, gg, scenario_ops, scenario_type_mapping)
        techs = groupby(gg, innergroupbycols)
        plot!(
            p,
            subplot = 6,
            title = "total",
        )
        for t in techs
            c = combine(groupby(t, :n), :time => sum)
            tech = first(t)
            x = c.n
            y = c.time_sum
            plot!(
                p, x, y,
                label = "$(tech.workers), $(tech.threads)",
                # linecolor = color_mapping[tech],
                subplot = 6
            )
        end
        plot!(p; plot_title = title, leftoverfontsizes...)
        DISPLAY_PLOTS && display(p)
        SAVE_PDF && savefig(p, SAVEDIR * filename("scenario", prefix, f) * ".pdf")
        SAVE_PLOTS && savefig(p, SAVEDIR * filename("scenario", prefix, f) * ".png")
    end
end
