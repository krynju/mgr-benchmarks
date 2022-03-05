DISPLAY_PLOTS = false
SAVE_PLOTS = true
SAVE_PDF = true
SAVEDIR = "plots/plots_dtable_chunksize/"

using Printf, Plots
include("load_data.jl")

_d = load_data()
sort!(_d, [:n, :time])
# _d = _d[_d.tech.=="dtable", :]
sort!(_d, :n)
mkpath(SAVEDIR)


using LaTeXStrings

function filename(group, prefix, f)
    "$(prefix)_$(group)_w=$(f.workers),t=$(f.threads),u=$(@sprintf("%.1E", f.unique_vals))"
end


chunksizenames = Dict(
    10000000 => L"1.0\times10^{7}",
    25000000 => L"2.5\times10^{7}",
)




groupbycols = [:workers, :threads, :unique_vals]
innergroupbycols = [:tech, :chunksize]
chunksizes = Int[1e7, 2.5e7]
chunksizes_colors = Dict(
    Int(1e7) => color_palette[1],
    Int(2.5e7) => color_palette[2],
)

allseries = [(ttt, kkk) for ttt in techs_list for kkk in chunksizes]
function getmarker(k)
    custom_markers[indexin(Ref(k), allseries)[1]]
end


function inner_loop(p, gg, ops)
    plot!(p;common_style_kwargs...)
    plot!(p;common_style_kwargs2...)

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
            groupkey = (tech = tech, chunksize = kk,)
            groupkey ∉ keys(config) && continue
            t = config[groupkey]
            x = t.n
            y = t.time
            plot!(
                p, x, y,
                # marker = :star,
                # markercolor = color_mapping[tech],
                # linecolor = chunksizes_colors[kk],
                label = chunksizenames[kk] * " $(techs_name_mapping[tech])",
                # xticks=(x, [ for a in x])
                marker=getmarker((tech, kk)),
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
    # ("all", _d),
    # ("wor", _d[_d.workers .!= 1, :]),
    ("thr", _d[_d.workers.==1, :]),
]
    dd = d[d.type.∈Ref(basic_ops), :]
    for gg in groupby(dd, groupbycols)
        f = first(gg)
        title = "ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
        p = plot(layout = length(basic_ops))
        p = inner_loop(p, gg, basic_ops)
        p = epi(p, title)
        saveplot(p, SAVEDIR, filename("basic", prefix, f))
    end

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
            groupkey = (tech = tech, chunksize = kk,)
            groupkey ∉ keys(config) && continue
            t = config[groupkey]
            c = combine(groupby(t, :n), :time => sum)
            x = c.n
            y = c.time_sum
            plot!(
                p, x, y,
                # label = chunksizenames[kk] * " $(techs_name_mapping[tech])",
                marker=getmarker((tech, kk)),
                subplot = 6,
                xticks=(x, xtickslabels),
                ; markerargs...
            )
        end
        p = epi(p, title)
        saveplot(p, SAVEDIR, filename("scenario", prefix, f))
    end
end
