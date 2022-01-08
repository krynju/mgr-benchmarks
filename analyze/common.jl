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
    "dtable" => "DTable",
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
    tickfontsize = 6,
    annotationfontsize = 6,
    titlefontsize = 8,
    labelfontsize = 6,)
common_style_kwargs2 = (
    link = :both,
)

leftoverfontsizes = (
    plot_titlefontsize = 10, legendfontsize = 5
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
    "increment_map" => "Mapowanie",
    "filter_half" => "Filtrowanie",
    "reduce_var_single" => "Redukcja (1 kolumna)",
    "reduce_var_all" => "Redukcja (4 kolumny)",
    "groupby_single_col" => "Redystrybucja",
    "innerjoin_r_unique" => "Łączenie tabeli",
    "grouped_reduce_mean_singlecol" => "Redukcja grupowa (1 kolumna)",
    "grouped_reduce_mean_allcols" => "Redukcja grupowa (4 kolumny)",
    "scenario_table_load" => "Ładowanie z dysku",
    "scenario_full_table_statistics" => "Statystyki pełne",
    "scenario_count_unique_a1" => "Zliczanie unikalnych wartości",
    "scenario_rowwise_sum_and_mean_reduce" => "Suma rzędu i redukcja",
    "scenario_grouped_a1_statistics" => "Statystyki grupowe",
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
