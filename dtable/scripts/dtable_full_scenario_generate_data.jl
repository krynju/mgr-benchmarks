using Pkg;
Pkg.activate(".");
using Random, Arrow


n = tryparse(Int, ARGS[1])
max_chunksize = tryparse(Int, ARGS[2])
unique_values = tryparse(Int32, ARGS[3])
ncolumns = tryparse(Int, ARGS[4])

# n = Int(1e8)
# max_chunksize = Int(1e7)
# unique_values = Int(1e3)
# ncolumns = 4

genchunk = (rng) -> (; [Symbol("a$i") => rand(rng, Int32(1):Int32(unique_values), n ÷ nchunks) for i = 1:ncolumns]...)
rm("data_arrow", recursive=true)
mkpath("data_arrow")


nchunks = (n + max_chunksize - 1) ÷ max_chunksize
for i = 1:nchunks
    Arrow.write(joinpath(["data_arrow", "datapart_$i.arrow"]), genchunk(MersenneTwister(1111+i)))
end
