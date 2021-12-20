runcmd() {
    echo "@@@ STARTING CONFIG: $1"
    eval $1
    sleep 2
    echo "@@@ ENDING CONFIG:   $1"
}

eval "julia -t4 init.jl"

trap "exit" INT
s="scripts/"

benchmarkloop() {
    if [[ $w -eq 1 ]]; then 
        juliacmd="julia -J /tmp/jlsysimage/sysimage.so -t$t"
    else
        juliacmd="julia -J /tmp/jlsysimage/sysimage.so -p$(($w-1)) -t$t"
    fi

    for n in "${ns[@]}"; do
        for chunksize in "${chunksizes[@]}"; do
            for uvc in "${unique_vals_count[@]}"; do
                if [ "$uvc" == "1000" ]; then
                    runcmd "$juliacmd ${s}dtable_basic.jl $n $chunksize $uvc $ncols"
                fi
                runcmd "$juliacmd ${s}dtable_groupby.jl $n $chunksize $uvc $ncols"
                runcmd "$juliacmd ${s}dtable_grouped_reduce.jl $n $chunksize $uvc $ncols"
                runcmd "$juliacmd ${s}dtable_innerjoin_unique.jl $n $chunksize $uvc $ncols"
            done
        done
    done

    for n in "${ns[@]}"; do
        for uvc in "${unique_vals_count[@]}"; do
            for chunksize in "${chunksizes[@]}"; do
                runcmd "$juliacmd ${s}dtable_full_scenario_generate_data.jl $n $chunksize $uvc $ncols"
                runcmd "$juliacmd ${s}dtable_full_scenario_stages_benchmark.jl $n $chunksize $uvc $ncols"
                runcmd "$juliacmd ${s}dtable_full_scenario_benchmark.jl $n $chunksize $uvc $ncols"
                rm -r data
            done
        done
    done
}


# # threaded
# workers="1"
# threads=('8' '16' '32')
# chunksizes=('10000000' '25000000')
# # ns=('10000000' '100000000' '500000000' '1000000000')
# ns=('10000000')
# unique_vals_count=('1000' '10000')
# ncols="4"

# for t in "${threads[@]}"; do
#     w=$workers
#     benchmarkloop
# done

# with workers
workers=('2' '4' '8' '12')
threads="4"
chunksizes=('10000000' '25000000')
# ns=('10000000' '100000000' '500000000' '1000000000' '2000000000' '3000000000')
ns=('10000000')
unique_vals_count=('1000')
ncols="4"

for w in "${workers[@]}"; do
    t=$threads
    benchmarkloop
done

# with workers bigger uvc
# ns=('10000000' '100000000' '500000000' '1000000000' '2000000000')
ns=('10000000')
ncols="4"
unique_vals_count=('10000')
for w in "${workers[@]}"; do
    t=$threads
    benchmarkloop
done
