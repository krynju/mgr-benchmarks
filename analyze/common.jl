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

techs_list = [
    "dtable",
    "dask",
    "spark",
]


techs_marker_mapping = Dict(
    "dtable" => :star,
    "dask" => :circle,
    "spark" => :diamond,
)

techs_name_mapping = Dict(
    "dtable" => "DTable.jl",
    "dask" => "Dask",
    "spark" => "PySpark",
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

advanced_ops = [
    "groupby_single_col",
    "innerjoin_r_unique",
    "grouped_reduce_mean_singlecol",
    "grouped_reduce_mean_allcols"
]


scenario_ops = [
    "scenario_table_load",
    "scenario_full_table_statistics",
    "scenario_grouped_a1_statistics",
    "scenario_count_unique_a1",
    "scenario_rowwise_sum_and_mean_reduce",
]

OPS_ALL = [
    "increment_map",
    "filter_half",
    "reduce_var_single",
    "reduce_var_all",
    "groupby_single_col",
    "innerjoin_r_unique",
    "grouped_reduce_mean_singlecol",
    "grouped_reduce_mean_allcols",
    "scenario_table_load",
    "scenario_full_table_statistics",
    "scenario_grouped_a1_statistics",
    "scenario_count_unique_a1",
    "scenario_rowwise_sum_and_mean_reduce",
]

common_style_kwargs = (
    fontfamily = "Computer Modern",
    xscale = :log10,
    yscale = :log10,
    xlabel = "Rozmiar tabeli [GB]",
    ylabel = "Czas wykonania [s]",
    tickfontsize = 7,
    annotationfontsize = 9,
    titlefontsize = 9,
    labelfontsize = 8,)
common_style_kwargs2 = (
    link = :both,
)

leftoverfontsizes = (
    plot_titlefontsize = 10, legendfontsize = 6
)

envsetupsorder = [
    (1, 2),
    (1, 4),
    (1, 8),
    (1, 16),
    (4, 4),
    (8, 4),
]

envsetupmapping = Dict(
    (1, 2) => "2 w.",
    (1, 4) => "4 w.",
    (1, 8) => "8 w.",
    (1, 16) => "16 w.",
    (4, 4) => "4 p.; 4 w.",
    (8, 4) => "8 p.; 4 w.",
)


envsetupcolormapping = Dict(
    (1, 2) => color_palette[1],
    (1, 4) => color_palette[2],
    (1, 8) => color_palette[3],
    (1, 16) => color_palette[4],
    (4, 4) => color_palette[5],
    (8, 4) => color_palette[10],
)

custom_color_palette = [
    color_palette[1],
    color_palette[2],
    color_palette[3],
    color_palette[4],
    color_palette[5],
    color_palette[10],
]


markerargs = (
    markersize = 3,
    markerstrokewidth = 0.5,
)

xtickslabels = ["0.16", "1.6", "8", "16", "32"]

OPS_NAME_MAPPING = Dict(
    "increment_map" => "map",
    "filter_half" => "filter",
    "reduce_var_single" => "reduce (jedna kolumna)",
    "reduce_var_all" => "reduce (cała tabela)",
    "groupby_single_col" => "groupby",
    "innerjoin_r_unique" => "innerjoin",
    "grouped_reduce_mean_singlecol" => "reduce pogrupowanej tabeli (jedna kolumna)",
    "grouped_reduce_mean_allcols" => "reduce pogrupowanej tabeli (cała tabela)",
    "scenario_table_load" => "Ładowanie z dysku",
    "scenario_full_table_statistics" => "Statystyki tabeli",
    "scenario_count_unique_a1" => "Zliczanie unikatowych wartości",
    "scenario_rowwise_sum_and_mean_reduce" => "Średnia sumy wierszy",
    "scenario_grouped_a1_statistics" => " Statystyki pogrup. tabeli",
    "total" => "Czas całkowity"
)

function populate_labels(p)
    plot!(p, xlabel = "", ylabel = "")
    for i in [1, 1 + size(p.layout.grid)[2]]
        plot!(p, subplot = i, ylabel = common_style_kwargs[:ylabel])
    end
    for i in (1+size(p.layout.grid)[2]):(size(p.layout.grid)[2]*size(p.layout.grid)[1])
        plot!(p, subplot = i, xlabel = common_style_kwargs[:xlabel])
    end
    p
end


custom_markers = [
    :circle, :rtriangle,
    :diamond, :hexagon,
    :utriangle, :star5, :ltriangle, :pentagon, :heptagon, :octagon, :star4, :star6, :star7, :star8, :vline, :hline, :+, :x
]

function epi(p, title)
    plot!(p, legend = :none)
    plot!(p, subplot = 1, legend = :topleft)
    # plot!(p; plot_title = title, leftoverfontsizes...)
    plot!(p; leftoverfontsizes...)
end
