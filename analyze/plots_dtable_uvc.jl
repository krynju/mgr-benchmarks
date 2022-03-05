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

allseries = [(ttt, kkk) for ttt in techs_list for kkk in unique_vals]

function getmarker(k)
    custom_markers[indexin(Ref(k), allseries)[1]]
end

function filename(group, prefix, f)
    "$(prefix)_$(group)_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize))"
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
        for (tech, kk) in allseries
            (tech = tech, unique_vals = kk,) ∉ keys(config) && continue
            t = config[(tech = tech, unique_vals = kk,)]

            x = t.n
            y = t.time
            plot!(
                p, x, y,
                label = L"10^{%$(floor(Int, log10(kk)))}" * " $(techs_name_mapping[tech])",
                # xticks=(x, [ for a in x])
                marker=getmarker((tech, kk)),
                # markercolor=envsetupcolormapping[(tech.workers, tech.threads)],
                # linecolor = envsetupcolormapping[(tech.workers, tech.threads)],
                subplot = i,
                xticks=(x, xtickslabels),
                ; markerargs...
            )
        end
    end
    p=populate_labels(p)
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
        p = inner_loop(p, gg, advanced_ops)
        p = epi(p, title)
        saveplot(p, SAVEDIR, filename("advanced", prefix, f))
    end


    dd = d[d.type.∈Ref(scenario_ops), :]
    for gg in groupby(dd, groupbycols)
        f = first(gg)
        title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
        p = plot(layout = length(scenario_ops) + 1,)
        p = inner_loop(p, gg, scenario_ops)
        config = groupby(gg, innergroupbycols)
        plot!(
            p,
            subplot = 6,
            title = OPS_NAME_MAPPING["total"],
        )
        for (tech, kk) in allseries
            (tech = tech, unique_vals = kk,) ∉ keys(config) && continue
            t = config[(tech = tech, unique_vals = kk,)]
            c = combine(groupby(t, :n), :time => sum)
            x = c.n
            y = c.time_sum
            plot!(
                p, x, y,
                # linecolor = envsetupcolormapping[(tech.workers, tech.threads)],
                subplot = 6,
                xticks=(x, xtickslabels),
                marker=getmarker((tech, kk)),
                # markercolor=envsetupcolormapping[(tech.workers, tech.threads)],
                ; markerargs...
            )
        end
        p = epi(p, title)
        saveplot(p, SAVEDIR, filename("scenario", prefix, f))
    end
end
