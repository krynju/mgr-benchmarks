# readdir("charts")
needed_charts =[
    "advanced_w=1,t=16,ch=1.0E+07,u=1.0E+03.pdf"
    "basic_w=1,t=16,ch=1.0E+07,u=1.0E+03.pdf"
    "dask_thr_advanced_ch=1.0E+07,u=1.0E+03.pdf"
    "dask_thr_basic_ch=1.0E+07,u=1.0E+03.pdf"
    "dask_thr_scenario_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_thr_advanced_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_thr_basic_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_thr_scenario_ch=1.0E+07,u=1.0E+03.pdf"
    "scenario_w=1,t=16,ch=1.0E+07,u=1.0E+03.pdf"
    "thr_advanced_w=1,t=16,ch=1.0E+07.pdf"
    "thr_advanced_w=1,t=16,u=1.0E+03.pdf"
    "thr_basic_w=1,t=16,u=1.0E+03.pdf"
    "thr_scenario_w=1,t=16,ch=1.0E+07.pdf"
    "thr_scenario_w=1,t=16,u=1.0E+03.pdf"
]

allplots = vcat(readdir.(readdir("plots", join=true),join=true)...)

chartdir = "charts"
mkpath(chartdir)

for n in needed_charts
    idxs = findall(x->occursin(n, x), allplots)
    @assert length(idxs) == 1
    cp(allplots[idxs[1]], joinpath(chartdir, n))
end