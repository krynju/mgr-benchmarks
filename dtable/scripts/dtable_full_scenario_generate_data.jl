using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using Dagger
@everywhere using DTables
@everywhere using CSV

include("intro_common.jl")

genchunk = (rng) -> (; [Symbol("a$i") => rand(rng, Int32(1):Int32(unique_values), n ÷ nchunks) for i = 1:ncolumns]...)
rm("data", recursive=true, force=true)
mkpath("data")

nchunks = (n + max_chunksize - 1) ÷ max_chunksize
for i = 1:nchunks
    CSV.write(joinpath(["data", "datapart_$i.csv"]), genchunk(MersenneTwister(1111+i)))
end

close(file)
