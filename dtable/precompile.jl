using Dagger, DataFrames, CSV, OnlineStats, Tables, BenchmarkTools
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
fetch(Dagger.groupby(dt, :a))
fetch(reduce(fit!, Dagger.groupby(dt, :a), cols=[:a], init=Variance()))
fetch(reduce(fit!, Dagger.groupby(dt, :a), init=Mean()))
fetch(innerjoin(dt, dt, on=:a))
@benchmark fetch(innerjoin(dt, dt, on=:a))
