basic_types = [
    "increment_map",
    "filter_half",
    "reduce_var_all",
    "reduce_var_single"
]
using Plots
color_palette = palette(:tab10)
color_mapping = Dict(
    "dtable" => color_palette[3],
    "dask" => color_palette[1],
    "spark" => color_palette[2]
)

basic_ops = [
    "increment_map",
    "filter_half",
    "reduce_var_single",
    "reduce_var_all"
]

color_palette = palette(:tab10)
color_mapping = Dict(
    "dtable" => color_palette[3],
    "dask" => color_palette[1],
    "spark" => color_palette[2]
)

basic_type_mapping = Dict(
    "increment_map" => "map",
    "filter_half" => "filter",
    "reduce_var_single" => "reduce (1 kolumna)",
    "reduce_var_all" => "reduce (4 kolumny)",
)

advanced_ops = [
    "groupby_single_col",
    "innerjoin_r_unique",
    "grouped_reduce_mean_singlecol",
    "grouped_reduce_mean_allcols"
]
advanced_type_mapping = Dict(
    "groupby_single_col" => "shuffle",
    "innerjoin_r_unique" => "inner join",
    "grouped_reduce_mean_singlecol" => "grouped reduce (1 kolumna)",
    "grouped_reduce_mean_allcols" => "grouped reduce (4 kolumny)",
)

scenario_ops = [
    "scenario_table_load",
    "scenario_full_table_statistics",
    "scenario_count_unique_a1",
    "scenario_rowwise_sum_and_mean_reduce",
    "scenario_grouped_a1_statistics"
]
scenario_type_mapping = Dict(
    "scenario_table_load" => "load",
    "scenario_full_table_statistics" => "basic stats",
    "scenario_count_unique_a1" => "count unique",
    "scenario_rowwise_sum_and_mean_reduce" => "rowwise",
    "scenario_grouped_a1_statistics" => "grouped stats",
)


common_style_kwargs = (
    fontfamily = "Computer Modern",
    xscale = :log10,
    yscale = :log10,
    xlabel = "n",
    ylabel = "Czas wykonania [s]",
    labelfontsize = 6,
    annotationfontsize = 6,
    legendfontsize = 5,
    titlefontsize = 6,
)