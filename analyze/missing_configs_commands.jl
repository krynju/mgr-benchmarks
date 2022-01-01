include("config_coverage.jl")

translate_dtable = Dict(
    "increment_map" => "scripts/dtable_basic.jl",
    "filter_half" => "scripts/dtable_basic.jl",
    "reduce_var_all" => "scripts/dtable_basic.jl",
    "reduce_var_single" => "scripts/dtable_basic.jl",
    "groupby_single_col" => "scripts/dtable_groupby.jl",
    "grouped_reduce_mean_singlecol" => "scripts/dtable_groupby_reduce.jl",
    "grouped_reduce_mean_allcols" => "scripts/dtable_groupby_reduce.jl",
    "innerjoin_r_unique" => "scripts/dtable_innerjoin_unique.jl",
    "scenario_table_load" => "scripts/dtable_full_scenario_load_benchmark.jl",
    "scenario_full_table_statistics" => "scripts/dtable_full_scenario_stages_benchmark.jl",
    "scenario_count_unique_a1" => "scripts/dtable_full_scenario_stages_benchmark.jl",
    "scenario_rowwise_sum_and_mean_reduce" => "scripts/dtable_full_scenario_stages_benchmark.jl",
    "scenario_grouped_a1_statistics" => "scripts/dtable_full_scenario_stages_benchmark.jl",
)

translate_dask = Dict(
    "increment_map" => "scripts/daskb_basic.jl",
    "filter_half" => "scripts/daskb_basic.jl",
    "reduce_var_all" => "scripts/daskb_basic.jl",
    "reduce_var_single" => "scripts/daskb_basic.jl",
    "groupby_single_col" => "scripts/daskb_groupby.jl",
    "grouped_reduce_mean_singlecol" => "scripts/daskb_groupby.jl",
    "grouped_reduce_mean_allcols" => "scripts/daskb_groupby.jl",
    "innerjoin_r_unique" => "scripts/daskb_join.jl",
    "scenario_table_load" => "scripts/daskb_scenario_stages_benchmark.jl",
    "scenario_full_table_statistics" => "scripts/daskb_scenario_stages_benchmark.jl",
    "scenario_count_unique_a1" => "scripts/daskb_scenario_stages_benchmark.jl",
    "scenario_rowwise_sum_and_mean_reduce" => "scripts/daskb_scenario_stages_benchmark.jl",
    "scenario_grouped_a1_statistics" => "scripts/daskb_scenario_stages_benchmark.jl",
)

translate_spark = Dict(
    "increment_map" => "scripts/spark_basic.jl",
    "filter_half" => "scripts/spark_basic.jl",
    "reduce_var_all" => "scripts/spark_basic.jl",
    "reduce_var_single" => "scripts/spark_basic.jl",
    "groupby_single_col" => "scripts/spark_groupby.jl",
    "grouped_reduce_mean_singlecol" => "scripts/spark_groupby.jl",
    "grouped_reduce_mean_allcols" => "scripts/spark_groupby.jl",
    "innerjoin_r_unique" => "scripts/spark_join.jl",
    "scenario_table_load" => "scripts/spark_scenario_stages_benchmark.jl",
    "scenario_full_table_statistics" => "scripts/spark_scenario_stages_benchmark.jl",
    "scenario_count_unique_a1" => "scripts/spark_scenario_stages_benchmark.jl",
    "scenario_rowwise_sum_and_mean_reduce" => "scripts/spark_scenario_stages_benchmark.jl",
    "scenario_grouped_a1_statistics" => "scripts/spark_scenario_stages_benchmark.jl",
)


dtable = select(d4, 1:5, :type => ByRow(x-> translate_dtable[x]) => :command, :time_dtable => ByRow((x)->"dtable") => :tech, :time_dtable => :time)
dask = select(d4, 1:5, :type => ByRow(x-> translate_dask[x]) => :command, :time_dtable => ByRow((x)->"dask") => :tech, :time_dask => :time)
spark = select(d4, 1:5, :type => ByRow(x-> translate_spark[x]) => :command, :time_dtable => ByRow((x)->"spark") => :tech, :time_spark => :time)

dtable = dtable[ismissing.(dtable.time), :]
dask = dask[ismissing.(dask.time), :]
spark = spark[ismissing.(spark.time), :]

dtable = combine(groupby(dtable, propertynames(dtable)[1:6]), first)
dask = combine(groupby(dask, propertynames(dask)[1:6]), first)
spark = combine(groupby(spark, propertynames(spark)[1:6]), first)