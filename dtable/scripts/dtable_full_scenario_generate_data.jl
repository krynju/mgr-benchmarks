using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using Dagger
@everywhere using CSV
# using Arrow

include("intro_common.jl")

genchunk = (rng) -> (; [Symbol("a$i") => rand(rng, Int32(1):Int32(unique_values), n ÷ nchunks) for i = 1:ncolumns]...)
# rm("data_arrow", recursive=true, force=true)
rm("data", recursive=true, force=true)
# mkpath("data_arrow")
mkpath("data")

nchunks = (n + max_chunksize - 1) ÷ max_chunksize
for i = 1:nchunks
    # Arrow.write(joinpath(["data_arrow", "datapart_$i.arrow"]), genchunk(MersenneTwister(1111+i)))
    CSV.write(joinpath(["data", "datapart_$i.csv"]), genchunk(MersenneTwister(1111+i)))
end

close(file)
