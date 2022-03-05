# readdir("charts")
needed_charts = [
    "advanced_w=1,t=16,ch=1.0E+07,u=1.0E+03.pdf"
    "advanced_w=8,t=4,ch=1.0E+07,u=1.0E+03.pdf"
    "basic_w=1,t=16,ch=1.0E+07,u=1.0E+03.pdf"
    "basic_w=8,t=4,ch=1.0E+07,u=1.0E+03.pdf"
    "dask_thr_advanced_ch=1.0E+07,u=1.0E+03.pdf"
    "dask_thr_basic_ch=1.0E+07,u=1.0E+03.pdf"
    "dask_thr_scenario_ch=1.0E+07,u=1.0E+03.pdf"
    "dask_wor_advanced_ch=1.0E+07,u=1.0E+03.pdf"
    "dask_wor_basic_ch=1.0E+07,u=1.0E+03.pdf"
    "dask_wor_scenario_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_all_advanced_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_all_basic_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_all_scenario_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_thr_advanced_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_thr_basic_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_thr_scenario_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_wor_advanced_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_wor_basic_ch=1.0E+07,u=1.0E+03.pdf"
    "dtable_wor_scenario_ch=1.0E+07,u=1.0E+03.pdf"
    "scenario_w=1,t=16,ch=1.0E+07,u=1.0E+03.pdf"
    "scenario_w=8,t=4,ch=1.0E+07,u=1.0E+03.pdf"
    "spark_wor_advanced_ch=1.0E+07,u=1.0E+03.pdf"
    "spark_wor_basic_ch=1.0E+07,u=1.0E+03.pdf"
    "spark_wor_scenario_ch=1.0E+07,u=1.0E+03.pdf"
    "thr_advanced_w=1,t=16,ch=1.0E+07.pdf"
    "thr_advanced_w=1,t=16,u=1.0E+03.pdf"
    "thr_basic_w=1,t=16,u=1.0E+03.pdf"
    "thr_scenario_w=1,t=16,ch=1.0E+07.pdf"
    "thr_scenario_w=1,t=16,u=1.0E+03.pdf"
    "wor_advanced_w=8,t=4,ch=1.0E+07.pdf"
    "wor_scenario_w=8,t=4,ch=1.0E+07.pdf"
]

needed_charts_png = map(x-> replace(x, ".pdf" =>".png"), needed_charts)

allplots = vcat(readdir.(readdir("plots", join = true), join = true)...)

chartdir = "charts"
mkpath(chartdir)

for n in needed_charts
    idxs = findall(x -> occursin(n, x), allplots)
    @assert length(idxs) == 1
    cp(allplots[idxs[1]], joinpath(chartdir, n), force = true)
end

chartdir = "charts_png"
mkpath(chartdir)

for n in needed_charts_png
    idxs = findall(x -> occursin(n, x), allplots)
    @assert length(idxs) == 1
    cp(allplots[idxs[1]], joinpath(chartdir, n), force = true)
end