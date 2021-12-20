
rcolnames = ["mean", "variance", "n", "min", "max", "nmin", "nmax"]
unwrap_series = (c) -> begin
    m, v, e = c
    (m.μ, v.μ, e.n, e.min, e.max, e.nmin, e.nmax)
end

save_results = (b, type) -> begin
    m = minimum(b)
    s = "dtable,$type,$n,$max_chunksize,$unique_values,$ncolumns,$(m.time),$(m.gctime),$(m.memory),$(m.allocs),$(nworkers()),$(Threads.nthreads())\n"
    write(file, s)
    flush(file)
end

mkpath("scenario_output")

##############

function scenario_table_load()
    d = DTable(x->CSV.read(x, NamedTuple, types=Int32), files_csv)
    # d = DTable(Arrow.Table, files_arrow)
    # d = DTable(Arrow.Table(files_arrow), max_chunksize; use_spawn=true)
    tabletype!(d)
    d
end

function scenario_full_table_statistics(d)
    s = Series(Mean(), Variance(), Extrema())
    r = fetch(reduce(fit!, d, init = s))
    rd = DataFrame(r)
    rd[:, :col] .= [Tables.columnnames(Tables.columns(d))...]
    select!(rd, :col, :stats => ByRow(unwrap_series) => rcolnames)
    # Arrow.write("series_result.arrow", rd)
    CSV.write("scenario_output/series_result.csv", rd)
    nothing
end

##########

function scenario_count_unique_a1(d)
    c = CountMap()
    r = fetch(reduce(fit!, d, cols=[:a1], init = c))
    rd = DataFrame((value=i[1], count=i[2]) for i in r.a1.value)
    # Arrow.write("countmap.arrow", rd)
    CSV.write("scenario_output/countmap.csv", rd)
end

#######################
# rowwise sum and reduce

function scenario_rowwise_sum_and_mean_reduce(d)
    m = fetch(reduce(fit!, map(row -> (r = sum(row),), d), init = Mean()))
    r = m.r.μ
end

function scenario_grouped_a1_statistics(d)
    d = Dagger.groupby(d, :a1)
    r = fetch(reduce(fit!, d, cols = [:a2, :a3, :a4], init = Series(Mean(), Variance(), Extrema())))
    rd = DataFrame(r)
    select!(rd, :a1, [r => ByRow(row -> unwrap_series(row.stats)) => r .* "_" .* rcolnames for r in names(rd)[2:end]]...)
    # Arrow.write("group_series_result.arrow", rd)
    CSV.write("scenario_output/group_series_result.csv", rd)
end

nothing
