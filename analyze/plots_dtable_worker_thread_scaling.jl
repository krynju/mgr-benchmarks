DISPLAY_PLOTS = false
SAVE_PLOTS = true
SAVE_PDF = true
SAVEDIR = "plots/plots_dtable_grouped/"

using Printf, Plots
include("load_data.jl")

_d = load_data()
sort!(_d, [:n, :time])
mkpath(SAVEDIR)

function filename(tech, group, prefix, f)
    "$(tech)_$(prefix)_$(group)_ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
end


groupbycols = [:chunksize, :unique_vals]
innergroupbycols = [:tech, :workers, :threads]
using LaTeXStrings

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
        for (tech, workers, threads) in [(ttt, www, kkk) for ttt in combine(gg, :tech => unique)[:, 1] for www in [1, 4, 8] for kkk in [2, 4, 8, 16]]
            groupkey = (tech = tech, workers = workers, threads = threads)
            groupkey ∉ keys(config) && continue
            t = config[groupkey]
            x = t.n
            y = t.time
            plot!(
                p, x, y,
                label = envsetupmapping[(workers, threads)],
                # marker = :star,
                # markercolor = color_mapping[tech],
                linecolor = envsetupcolormapping[(workers, threads)],
                subplot = i,
                # xticks=(x, [L"%10^{%$(floor(Int, log10(a)))}" for a in x])
                xticks=(x, ["0.16", "1.6", "8", "16", "32"])
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


for _tech in techs_list

    d2 = _d[_d.tech.==_tech, :]
    for (prefix, d) in [
        ("all", d2),
        ("wor", d2[d2.workers.!=1, :]),
        ("thr", d2[d2.workers.==1, :]),
    ]
        dd = d[d.type.∈Ref(basic_ops), :]
        for gg in groupby(dd, groupbycols)
            f = first(gg)
            title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
            p = plot(layout = length(basic_ops))
            p = inner_loop(p, gg, basic_ops, basic_type_mapping)
            plot!(p; plot_title = title, leftoverfontsizes...)
            DISPLAY_PLOTS && display(p)
            SAVE_PLOTS && savefig(p, SAVEDIR * filename(_tech, "basic", prefix, f) * ".png")
            SAVE_PDF && savefig(p, SAVEDIR * filename(_tech, "basic", prefix, f) * ".pdf")
        end

        dd = d[d.type.∈Ref(advanced_ops), :]

        for gg in groupby(dd, groupbycols)
            f = first(gg)
            title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
            p = plot(layout = length(advanced_ops),)
            p = inner_loop(p, gg, advanced_ops, advanced_type_mapping)
            plot!(p; plot_title = title, leftoverfontsizes...)
            DISPLAY_PLOTS && display(p)
            SAVE_PDF && savefig(p, SAVEDIR * filename(_tech, "advanced", prefix, f) * ".pdf")
            SAVE_PLOTS && savefig(p, SAVEDIR * filename(_tech, "advanced", prefix, f) * ".png")
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
                    linecolor = envsetupcolormapping[(tech.workers, tech.threads)],
                    subplot = 6,
                    xticks=(x, ["0.16", "1.6", "8", "16", "32"])
                )
            end
            plot!(p; plot_title = title, leftoverfontsizes...)
            DISPLAY_PLOTS && display(p)
            SAVE_PDF && savefig(p, SAVEDIR * filename(_tech, "scenario", prefix, f) * ".pdf")
            SAVE_PLOTS && savefig(p, SAVEDIR * filename(_tech, "scenario", prefix, f) * ".png")
        end
    end
end