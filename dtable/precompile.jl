using Dagger, DataFrames, CSV, OnlineStats, Tables, BenchmarkTools, DTables
f = Dagger.@spawn 10+10
fetch(f)

nt = (a=collect(1:100).%10, b=rand(100))
d = DataFrame(nt)

i = IOBuffer()
CSV.write(i, d)
o = CSV.read(take!(i), DataFrame)

dt = DTable(d, 10, tabletype=NamedTuple)
fetch(map(x->(r=x.a+x.b,), dt))
fetch(filter(x->x.a>5, dt))
fetch(reduce(fit!, dt, cols=[:a], init=Variance()))
fetch(reduce(fit!, dt, init=Mean()))
fetch(DTables.groupby(dt, :a))
fetch(reduce(fit!, DTables.groupby(dt, :a), cols=[:a], init=Variance()))
fetch(reduce(fit!, DTables.groupby(dt, :a), init=Mean()))
fetch(innerjoin(dt, dt, on=:a))
@benchmark fetch(innerjoin(dt, dt, on=:a))
