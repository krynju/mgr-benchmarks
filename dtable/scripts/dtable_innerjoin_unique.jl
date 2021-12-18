using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using Dagger

include("intro_common.jl")

d2 = DTable((a1=Int32.(0:unique_values-1), a5=.-Int32.(0:unique_values-1)), Int(unique_values))

groupby_single_col = (d, d2) -> begin
    j = Dagger.innerjoin(d, d2, on=:a1, r_unique=true)
    wait.(j.chunks)
    nothing
end
w_test("innerjoin_r_unique", groupby_single_col, d, s=1, second_arg=d2)


close(file)