@everywhere using Random, BenchmarkTools, OnlineStats, Dates

n = tryparse(Int, ARGS[1])
max_chunksize = tryparse(Int, ARGS[2])
unique_values = tryparse(Int32, ARGS[3])
ncolumns = tryparse(Int, ARGS[4])

# n = Int(1e7)
# max_chunksize = Int(1e7)
# unique_values = Int(1e3)
# ncolumns = 4

tablesize = sizeof(Int32) * ncolumns * n / 1_000_000
println("@@@ TABLESIZE:       $tablesize MB")

mkpath("results")
filename = joinpath(["results", "dtable_bench" * string(round(Int, Dates.datetime2unix(now()))) * ".csv"])
file = open(filename, "w")
println("@@@ SAVING TO:       $filename")
write(file, "tech,type,n,chunksize,unique_vals,ncolumns,time,gctime,memory,allocs,workers,threads\n")


run_bench = (f, arg, second_arg, s) -> begin
    if second_arg === nothing
        @benchmark $f($arg) samples=s evals=1 gcsample=true
    else
        @benchmark $f($arg, $second_arg) samples=s evals=1 gcsample=true
    end
end

_gc = () -> begin
    for i in 1:20
        Dagger.@spawn 10+10
        GC.gc()
    end
end

w_test = (type, f, arg; s=2, prefix="dtable_new", second_arg=nothing) -> begin
    _gc()
    println("@@@ STARTED:         $type : $(now())")
    b = run_bench(f, arg, second_arg, s)
    m = minimum(b)
    s = "$prefix,$type,$n,$max_chunksize,$unique_values,$ncolumns,$(m.time),$(m.gctime),$(m.memory),$(m.allocs),$(nprocs()),$(Threads.nthreads())\n"
    write(file, s)
    flush(file)
    println("@@@ DONE:            $type : $(now())")
    _gc()
    b
end

_gc = () -> begin
    for i in 1:10
        Dagger.@spawn 10+10
    end
    for i in 1:4
        GC.gc()
    end
end

nchunks = (n+max_chunksize-1) ÷ max_chunksize

genchunk = (rng) -> (;[Symbol("a$i") => rand(rng, Int32(1):Int32(unique_values), n÷nchunks) for i in 1:ncolumns]...)
