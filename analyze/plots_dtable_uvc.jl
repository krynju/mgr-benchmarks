DISPLAY_PLOTS = false
SAVE_PLOTS = true
SAVE_PDF = true
SAVEDIR = "plots/plots_dtable_uvc/"

using Printf, Plots
include("load_data.jl")

_d = load_data()
sort!(_d, [:n, :time])
mkpath(SAVEDIR)


using LaTeXStrings

groupbycols = [:workers, :threads, :chunksize]
innergroupbycols = [:tech, :unique_vals]
unique_vals = Int[1e3, 1e4]
unique_vals_colors = Dict(
    Int(1e3) => color_palette[1],
    Int(1e4) => color_palette[2],
)


function filename(group, prefix, f)
    "$(prefix)_$(group)_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize))"
end

function inner_loop(p, gg, ops, type_mapping)
    plot!(p;
        xscale = :log10,
        yscale = :log10,
        # size=(640,640),
        common_style_kwargs...)
    for (i, k) in enumerate(ops)
        g = groupby(gg, :type)[(type = k,)]
        config = groupby(g, innergroupbycols)
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = type_mapping[fg.type],
        )
        for (tech, kk) in [(ttt, kkk) for ttt in techs_list for kkk in unique_vals]
            (tech = tech, unique_vals = kk,) ∉ keys(config) && continue
            t = config[(tech = tech, unique_vals = kk,)]
            # tech = first(t)
            x = t.n
            y = t.time
            plot!(
                p, x, y,
                label = "$tech $kk",
                # marker = :star,
                # markercolor = color_mapping[tech],
                # linecolor = unique_vals_colors[kk],
                subplot = i,
                xticks=(x, ["0.16", "1.6", "8", "16", "32"]),
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
    ("all", _d),
    ("wor", _d[_d.workers.!=1, :]),
    ("thr", _d[_d.workers.==1, :]),
]
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
                xticks=(x, ["0.16", "1.6", "8", "16", "32"]),
                # linecolor = color_mapping[tech],
                subplot = 6,
            )
        end
        plot!(p; plot_title = title, leftoverfontsizes...)
        DISPLAY_PLOTS && display(p)
        SAVE_PDF && savefig(p, SAVEDIR * filename("scenario", prefix, f) * ".pdf")
        SAVE_PLOTS && savefig(p, SAVEDIR * filename("scenario", prefix, f) * ".png")
    end
end
