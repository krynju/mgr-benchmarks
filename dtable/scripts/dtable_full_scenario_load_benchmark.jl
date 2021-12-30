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

b = @benchmark begin
    scenario_table_load()
end samples=1 evals=1 gcsample=false
save_results(b, "scenario_table_load")

close(file)