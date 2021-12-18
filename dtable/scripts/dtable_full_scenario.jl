using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using Dagger, Random
using DataFrames, Arrow, Tables, OnlineStats

n = tryparse(Int, ARGS[1])
max_chunksize = tryparse(Int, ARGS[2])
unique_values = tryparse(Int32, ARGS[3])
ncolumns = tryparse(Int, ARGS[4])

# n = Int(1e8)
# max_chunksize = Int(1e7)
# unique_values = Int(1e3)
# ncolumns = 4

genchunk = (rng) -> (; [Symbol("a$i") => rand(rng, Int32(1):Int32(unique_values), n ÷ nchunks) for i = 1:ncolumns]...)
mkpath("data_arrow")

nchunks = (n + max_chunksize - 1) ÷ max_chunksize
for i = 1:nchunks
    # Arrow.write(joinpath(["data_arrow", "datapart_$i.arrow"]), genchunk(MersenneTwister(1111+i)))
end

files_arrow = readdir("data_arrow", join = true)

d = DTable(Arrow.Table, files_arrow)
# d = DTable(Arrow.Table(files_arrow), max_chunksize; use_spawn=true)

tabletype!(d)

##############
rcolnames = ["mean", "variance", "n", "min", "max", "nmin", "nmax"]
unwrap_series = (c) -> begin
    m, v, e = c
    (m.μ, v.μ, e.n, e.min, e.max, e.nmin, e.nmax)
end

s = Series(Mean(), Variance(), Extrema())
@time r = fetch(reduce(fit!, d, init = s))
rd = DataFrame(r)
rd[:, :col] .= [Tables.columnnames(Tables.columns(d))...]
select!(rd, :col, :stats => ByRow(unwrap_series) => rcolnames)
Arrow.write("series_result.arrow")

##########

c = CountMap()
@time r = fetch(reduce(fit!, d, cols=[:a1], init = c))
rd = DataFrame((value=i[1], count=i[2]) for i in r.a1.value)
Arrow.write("countmap.arrow", rd)

#######################
# rowwise sum and reduce

@time m = fetch(reduce(fit!, map(row -> (r = sum(row),), d), init = Mean()))
r = m.r.μ


#########################
d = Dagger.groupby(d, :a1)
r = fetch(reduce(fit!, d, cols = [:a2, :a3, :a4], init = s))
rd = DataFrame(r)
select!(rd, :a1, [r => ByRow(row -> unwrap_series(row.stats)) => r .* "_" .* rcolnames for r in names(rd)[2:end]]...)

Arrow.write("group_series_result.arrow", rd)