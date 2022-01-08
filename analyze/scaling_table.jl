include("load_data.jl")

d = load_data()
sort!(d, :time)

using Statistics
function process(d2)
    d2 = select(d2, 1:9)
    d2 = sort(d2, [:type, :threads])
    d2 = select(d2, :type, :threads, :time)
    dd = select(d2[d2.threads.==2,:], :type,  :time => :time_2)
    for i in [4,8,16]
        dd = leftjoin(dd, select(d2[d2.threads.==i,:], :type,  :time => "time_$i"), on=:type)
    end
    dj = DataFrame(type=OPS_ALL, i=1:length(OPS_ALL))
    dd = leftjoin(dd, dj, on=:type)
    f = (x,y) -> round.(x./y, digits=2)
    dd = transform(dd,
        [:time_2, :time_4] => f => :ratio_4,
        [:time_2, :time_8] => f => :ratio_8,
        [:time_2, :time_16] => f => :ratio_16,
    )
    sort!(dd, :i)
    dd.type = replace(dd.type, OPS_NAME_MAPPING...)
    cc = combine(dd, 1=>((x)->"średnia") , 7=>mean, 8=>mean, 9=>mean)
    select!(dd, 1=>"operacja",2=>"2 wątków czas",3=>"4 wątków czas", 4=>"8 wątków czas", 5=>"16 wątków czas", 7=>"4 wątki", 8=>"8 wątków", 9=>"16 wątków")

    dd
end

d2 = d[(d.workers .==1).&(d.tech .== "dtable").&(d.chunksize.==Int(1e7)).&(d.unique_vals.==1000).&(d.n.==Int(5e8)), :]

# process(d2)
CSV.write("dtable_thread_scaling.csv", process(d2))


d2 = d[(d.workers .==1).&(d.tech .== "dask").&(d.chunksize.==Int(1e7)).&(d.unique_vals.==1000).&(d.n.==Int(5e8)), :]
CSV.write("dask_thread_scaling.csv", process(d2))



# workers
function process_workers(d2)
    d2 = select(d2, 1:9)
    d2 = sort(d2, [:type, :workers])
    d2 = select(d2, :type, :workers, :time)
    dd = select(d2[d2.workers.==4,:], :type, :time => :time_4)
    dd = leftjoin(dd, select(d2[d2.workers.==8,:], :type,  :time => "time_8"), on=:type)

    dj = DataFrame(type=OPS_ALL, i=1:length(OPS_ALL))
    dd = leftjoin(dd, dj, on=:type)
    f = (x,y) -> round.(x./y, digits=2)
    dd = transform(dd,
        [:time_4, :time_8] => f => :speedup,
    )
    sort!(dd, :i)
    dd.type = replace(dd.type, OPS_NAME_MAPPING...)
    # cc = combine(dd, 1=>((x)->"średnia") , 7=>mean, 8=>mean, 9=>mean)
    # select!(dd, 1=>"operacja",2=>"2 wątków czas",3=>"4 wątków czas",  4=>"8 wątków czas", 5=>"16 wątków czas", 7=>"4 wątki", 8=>"8 wątków", 9=>"16 wątków")
    dd
end

d2 = d[(d.workers .!=1).&(d.tech .== "dtable").&(d.chunksize.==Int(1e7)).&(d.unique_vals.==1000).&(d.n.==Int(2e9)), :];
process_workers(d2)

CSV.write("dtable_worker_scaling.csv", process_workers(d2))


d2 = d[(d.workers .!=1).&(d.tech .== "dask").&(d.chunksize.==Int(1e7)).&(d.unique_vals.==1000).&(d.n.==Int(2e9)), :]
process_workers(d2)
CSV.write("dask_worker_scaling.csv", process_workers(d2))


d2 = d[(d.workers .!=1).&(d.tech .== "spark").&(d.chunksize.==Int(1e7)).&(d.unique_vals.==1000).&(d.n.==Int(2e9)), :]
process_workers(d2)
CSV.write("spark_worker_scaling.csv", process_workers(d2))





