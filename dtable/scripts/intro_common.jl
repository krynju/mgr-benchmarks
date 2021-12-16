@everywhere using Random, BenchmarkTools, OnlineStats, Dates

n = tryparse(Int, ARGS[1])
max_chunksize = tryparse(Int, ARGS[2])
unique_values = tryparse(Int32, ARGS[3])
ncolumns = tryparse(Int, ARGS[4])

tablesize = sizeof(Int32) * ncolumns * n / 1_000_000
println("@@@ TABLESIZE:       $tablesize MB")

mkpath("results")
filename = joinpath(["results", "dtable_bench" * string(round(Int, Dates.datetime2unix(now()))) * ".csv"])
file = open(filename, "w")
println("@@@ SAVING TO:       $filename")
write(file, "tech,type,n,chunksize,unique_vals,ncolumns,time,gctime,memory,allocs\n")


run_bench = (f, arg, second_arg, s) -> begin
    if second_arg === nothing
        @benchmark $f($arg) samples=s evals=1 gcsample=true
    else
        @benchmark $f($arg, $second_arg) samples=s evals=1 gcsample=true
    end
end

_gc = () -> begin
    for i in 1:4
        GC.gc()
    end
end

w_test = (type, f, arg; s=2, prefix="dtable", second_arg=nothing) -> begin
    b = run_bench(f, arg, second_arg, s)
    m = minimum(b)
    s = "$prefix,$type,$n,$max_chunksize,$unique_values,$ncolumns,$(m.time),$(m.gctime),$(m.memory),$(m.allocs)\n"
    write(file, s)
    flush(file)
    println("@@@ DONE:            $type")
    _gc()
    b
end

# rng = MersenneTwister(1111)
# data = (;[Symbol("a$i") => rand(rng, Int32(1):Int32(unique_values), n) for i in 1:ncolumns]...)

_gc = () -> begin
    for i in 1:10
        Dagger.@spawn 10+10
    end
    for i in 1:4
        GC.gc()
    end
end

# n = Int(5*1e8)
# max_chunksize = Int(1e7)
# unique_values = Int(1e4)
# ncolumns = 4

# d = DTable(data, max_chunksize)
# data = nothing

nchunks = (n+max_chunksize-1) ÷ max_chunksize

genchunk = (rng) -> (;[Symbol("a$i") => rand(rng, Int32(1):Int32(unique_values), n÷nchunks) for i in 1:ncolumns]...)

d = DTable([Dagger.@spawn genchunk(MersenneTwister(1111+i)) for i in 1:nchunks], NamedTuple)

_gc(); _gc(); _gc();
