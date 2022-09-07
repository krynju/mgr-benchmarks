using Distributed
@everywhere using Pkg;
@everywhere Pkg.activate(".");
@everywhere using Dagger
@everywhere using DTables

include("intro_common.jl")
include("generate_dtable.jl")

d2 = DTable((a1=Int32.(1:unique_values), a5=.-Int32.(1:unique_values)), Int(unique_values))

groupby_single_col = (d, d2) -> begin
    j = DTables.innerjoin(d, d2, on=:a1, r_unique=true)
    wait.(j.chunks)
    nothing
end
w_test("innerjoin_r_unique", groupby_single_col, d, s=1, second_arg=d2)


close(file)
