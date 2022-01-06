include("load_data.jl")

d = load_data()
sort!(d, :time)
d = combine(groupby(d, [:tech, :type, :chunksize, :n, :unique_vals, :workers, :threads]), first)

using Statistics
function process(d2)
    d2 = select(d2, 1:9)
    d2 = sort(d2, [:type, :threads])
    d2 = select(d2, 2,7,9)
    dd = select(d2[d2.threads.==2,:], :type,  :time => :time_2)
    for i in [4,8,16]
        dd = leftjoin(dd, select(d2[d2.threads.==i,:], :type,  :time => "time_$i"), on=:type)
    end
    f = (x,y) -> round.(x./y, digits=2)
    dd = transform(dd,
        [:time_2, :time_2] => f => :ratio_2,
        [:time_2, :time_4] => f => :ratio_4,
        [:time_2, :time_8] => f => :ratio_8,
        [:time_2, :time_16] => f => :ratio_16,
    )
    cc = combine(dd, 1=>((x)->"średnia") , 7=>mean, 8=>mean, 9=>mean)
    select!(dd, 1=>"operacja",2=>"2 wątków czas",3=>"4 wątków czas",  4=>"8 wątków czas", 5=>"16 wątków czas", 7=>"4 wątki", 8=>"8 wątków", 9=>"16 wątków")
    dd
end

d2 = d[(d.workers .==1).&(d.tech .== "dtable").&(d.chunksize.==Int(1e7)).&(d.unique_vals.==1000).&(d.n.==Int(5e8)), :]

process(d2)
# CSV.write("dtable_thread_scaling.csv", process(d2))


d2 = d[(d.workers .==1).&(d.tech .== "dask").&(d.chunksize.==Int(1e7)).&(d.unique_vals.==1000).&(d.n.==Int(5e8)), :]
# CSV.write("dask_thread_scaling.csv", process(d2))



# threaded fragment size scaling







