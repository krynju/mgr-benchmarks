using Printf, Plots
include("load_data.jl")





d = load_data()
d = combine(groupby(d, [:tech, :type, :chunksize, :n, :unique_vals, :workers, :threads]), first)
sort!(d, :n)
mkpath("plots2")


basic_ops = ["increment_map", "filter_half", "reduce_var_single", "reduce_var_all"]
dd = d[d.type .∈ Ref(basic_ops), :]
type_mapping = Dict(
    "increment_map" => "map",
    "filter_half" => "filter",
    "reduce_var_single" => "reduce (1 kolumna)",
    "reduce_var_all" => "reduce (4 kolumny)",
)

for gg in groupby(dd, [:chunksize, :unique_vals, :workers, :threads])
    f = first(gg)
    title = "$(f.type)\nw=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        xscale=:log10,
        yscale=:log10,
        layout=length(basic_ops),
    )
    
    for (i, k) in enumerate(basic_ops)
        g = groupby(gg, :type)[(type=k,)]
        techs = groupby(g, :tech)
        fg = first(g)
        plot!(
            p,
            subplot=i,
            title=type_mapping[fg.type],
        )
        for t in techs
            tech = first(t.tech)
            x = t.n
            y = t.time / 1e9
            plot!(
                p, x, y,
                label=tech,
                linecolor=color_mapping[tech],
                subplot=i
            )
        end
    end
    plot!(p, legend=:none)
    plot!(p, subplot=1, legend=:topleft)
    display(p)
    @async savefig(p, "plots2/basic_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end




advanced_ops = ["groupby_single_col", "innerjoin_r_unique", "grouped_reduce_mean_singlecol", "grouped_reduce_mean_allcols"]
dd = d[d.type .∈ Ref(advanced_ops), :]

type_mapping = Dict(
    "groupby_single_col" => "shuffle",
    "innerjoin_r_unique" => "inner join",
    "grouped_reduce_mean_singlecol" => "grouped reduce (1 kolumna)",
    "grouped_reduce_mean_allcols" => "grouped reduce (4 kolumny)",
)

for gg in groupby(dd, [:chunksize, :unique_vals, :workers, :threads])
    f = first(gg)
    title = "$(f.type)\nw=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        xscale=:log10,
        yscale=:log10,
        layout=length(advanced_ops),
    )
    
    for (i, k) in enumerate(advanced_ops)
        g = groupby(gg, :type)[(type=k,)]
        techs = groupby(g, :tech)
        fg = first(g)
        plot!(
            p,
            subplot=i,
            title=type_mapping[fg.type],
        )
        for t in techs
            tech = first(t.tech)
            x = t.n
            y = t.time / 1e9
            plot!(
                p, x, y,
                label=tech,
                linecolor=color_mapping[tech],
                subplot=i
            )
        end
    end
    plot!(p, legend=:none)
    plot!(p, subplot=1, legend=:topleft)
    display(p)
    @async savefig(p, "plots2/advanced_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end


scenario_ops = ["scenario_table_load", "scenario_full_table_statistics", "scenario_count_unique_a1", "scenario_rowwise_sum_and_mean_reduce", "scenario_grouped_a1_statistics"]
dd = d[d.type .∈ Ref(scenario_ops), :]

type_mapping = Dict(
    "scenario_table_load" => "a",
    "scenario_full_table_statistics" => "b" ,
     "scenario_count_unique_a1" => "c",
      "scenario_rowwise_sum_and_mean_reduce" => "d",
       "scenario_grouped_a1_statistics"=> "e",
)

for gg in groupby(dd, [:chunksize, :unique_vals, :workers, :threads])
    f = first(gg)
    title = "$(f.type)\nw=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals))"
    p = plot(
        xscale=:log10,
        yscale=:log10,
        layout=length(scenario_ops),
    )
    
    for (i, k) in enumerate(scenario_ops)
        g = groupby(gg, :type)[(type=k,)]
        techs = groupby(g, :tech)
        fg = first(g)
        plot!(
            p,
            subplot=i,
            title=type_mapping[fg.type],
        )
        for t in techs
            tech = first(t.tech)
            x = t.n
            y = t.time / 1e9
            plot!(
                p, x, y,
                label=tech,
                linecolor=color_mapping[tech],
                subplot=i
            )
        end
    end
    plot!(p, legend=:none)
    plot!(p, subplot=1, legend=:topleft)
    display(p)
    @async savefig(p, "plots2/scenario_w=$(f.workers),t=$(f.threads),ch=$(@sprintf("%.1E", f.chunksize)),u=$(@sprintf("%.1E", f.unique_vals)).png")
end