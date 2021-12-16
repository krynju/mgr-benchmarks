using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using Dagger

include("intro_common.jl")

r_n = 10000
d2 = DTable((a1=rand(Int32, r_n).%unique_values, b=rand(r_n) ), r_n)

groupby_single_col = (d, d2) -> begin
    j = Dagger.innerjoin(d, d2, on=:a1)
    wait.(j.chunks)
    nothing
end
w_test("innerjoin_r_1e3", groupby_single_col, d, s=1, second_arg=d2)


close(file)