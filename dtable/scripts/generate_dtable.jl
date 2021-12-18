d = DTable([Dagger.@spawn genchunk(MersenneTwister(1111+i)) for i in 1:nchunks], NamedTuple)

_gc(); _gc(); _gc();