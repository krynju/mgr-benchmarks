using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using Dagger
@everywhere using CSV
@everywhere using DataFrames

include("intro_common.jl")
include("dtable_full_scenario_stages.jl")

# files_arrow = readdir("data_arrow", join = true)
files_csv = readdir("data", join = true)

b = @benchmark begin
    scenario_table_load()
end samples=1 evals=1 gcsample=false
_gc()
d = scenario_table_load()
_gc()

##############


b = @benchmark begin
    scenario_full_table_statistics(d)
end samples=1 evals=1 gcsample=false

save_results(b, "scenario_full_table_statistics")
_gc()
##########

b = @benchmark begin
    scenario_count_unique_a1(d)
end samples=1 evals=1 gcsample=false

save_results(b, "scenario_count_unique_a1")
_gc()
#######################
# rowwise sum and reduce
b = @benchmark begin
    scenario_rowwise_sum_and_mean_reduce(d)
end samples=1 evals=1 gcsample=false
save_results(b, "scenario_rowwise_sum_and_mean_reduce")
_gc()
#########################
b = @benchmark begin
    scenario_grouped_a1_statistics(d)
end samples=1 evals=1 gcsample=false
save_results(b, "scenario_grouped_a1_statistics")
close(file)