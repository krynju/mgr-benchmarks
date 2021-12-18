using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using Dagger

include("intro_common.jl")

################
# grouped prep
_gc()
d = Dagger.groupby(d, :a1)
_gc()
_gc()
################

grouped_reduce_mean_singlecol = (g) -> begin
    r = reduce(fit!, g, cols=[:a2], init=Mean())
    fetch(r)
end
w_test("grouped_reduce_mean_singlecol", grouped_reduce_mean_singlecol, d)


grouped_reduce_mean_allcols = (g) -> begin
    r = reduce(fit!, g, init=Mean())
    fetch(r)
end
w_test("grouped_reduce_mean_allcols", grouped_reduce_mean_allcols, d)


close(file)