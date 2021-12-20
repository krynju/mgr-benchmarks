using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using Dagger
# @everywhere using CSV
@everywhere using DataFrames

include("intro_common.jl")
include("dtable_full_scenario_stages.jl")

# files_arrow = readdir("data_arrow", join = true)

files_csv = readdir("data", join = true)

##############
b = @benchmark begin
    d = scenario_table_load()
    scenario_full_table_statistics(d)
    scenario_count_unique_a1(d)
    scenario_rowwise_sum_and_mean_reduce(d)
    scenario_grouped_a1_statistics(d)
end samples=1 evals=1 gcsample=false

save_results(b, "scenario_full_run")
close(file)