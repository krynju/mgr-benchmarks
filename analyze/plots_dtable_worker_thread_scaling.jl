DISPLAY_PLOTS = false
SAVE_PLOTS = true
SAVE_PDF = true
SAVEDIR = "plots/plots_dtable_wt_scaling/"

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

allseries = [(ttt, www, kkk) for ttt in combine(_d, :tech => unique)[:, 1] for www in [1, 4, 8] for kkk in [2, 4, 8, 16]]
allseries2 = [(1,2),(1,4),(1,8),(1,16),(4,4),(8,4) ]
function getmarker(k)
    custom_markers[indexin(Ref(k), allseries2)[1]]
end

function inner_loop(p, gg, ops)
    plot!(p;common_style_kwargs...)

    for (i, k) in enumerate(ops)
        g = groupby(gg, :type)[(type = k,)]
        config = groupby(g, innergroupbycols)
        fg = first(g)
        plot!(
            p,
            subplot = i,
            title = OPS_NAME_MAPPING[fg.type],
        )
        for (tech, workers, threads) in allseries
            groupkey = (tech = tech, workers = workers, threads = threads)
            groupkey ∉ keys(config) && continue
            t = config[groupkey]
            x = t.n
            y = t.time
            plot!(
                p, x, y,
                label = envsetupmapping[(workers, threads)],
                marker=getmarker((workers, threads)),
                markercolor=envsetupcolormapping[(workers, threads)],
                linecolor = envsetupcolormapping[(workers, threads)],
                subplot = i,
                xticks=(x, xtickslabels),
                ; markerargs...
            )
        end
    end
    p=populate_labels(p)
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
            p = inner_loop(p, gg, basic_ops)
            p = epi(p, title)
            saveplot(p, SAVEDIR, filename(_tech, "basic", prefix, f))
        end

        dd = d[d.type.∈Ref(advanced_ops), :]
        for gg in groupby(dd, groupbycols)
            f = first(gg)
            title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
            p = plot(layout = length(advanced_ops),)
            p = inner_loop(p, gg, advanced_ops)
            p = epi(p, title)
            saveplot(p, SAVEDIR, filename(_tech, "advanced", prefix, f))
        end


        dd = d[d.type.∈Ref(scenario_ops), :]
        for gg in groupby(dd, groupbycols)
            f = first(gg)
            title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
            p = plot(layout = length(scenario_ops) + 1)
            p = inner_loop(p, gg, scenario_ops)
            techs = groupby(gg, innergroupbycols)
            plot!(p,
                subplot = 6,
                title = OPS_NAME_MAPPING["total"],
            )
            for (tech, workers, threads) in allseries
                groupkey = (tech = tech, workers = workers, threads = threads)
                groupkey ∉ keys(techs) && continue
                t = techs[groupkey]
                c = combine(groupby(t, :n), :time => sum)
                tech = first(t)
                x = c.n
                y = c.time_sum
                plot!(
                    p, x, y,
                    label = envsetupmapping[(tech.workers, tech.threads)],
                    linecolor = envsetupcolormapping[(tech.workers, tech.threads)],
                    subplot = 6,
                    xticks=(x, xtickslabels),
                    marker=getmarker((workers, threads)),
                    markercolor=envsetupcolormapping[(tech.workers, tech.threads)],
                    ; markerargs...
                )
            end
            p = epi(p, title)
            saveplot(p, SAVEDIR, filename(_tech, "scenario", prefix, f))
        end
    end
end