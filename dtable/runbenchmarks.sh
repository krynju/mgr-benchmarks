runcmd() {
    echo "@@@ STARTING CONFIG: $1"
    eval $1
    sleep 2
    echo "@@@ ENDING CONFIG:   $1"
}

eval "julia -t4 init.jl"

trap "exit" INT
s="scripts/"

# sysimagepath="sysimage.so"
# juliapath="~/../../cygwin64/home/krynjupc/julia/julia.bat"
sysimagepath="/tmp/jlsysimage/sysimage.so"
juliapath="julia"

benchmarkloop() {
    if [[ $w -eq 1 ]]; then 
        juliacmd="$juliapath -J $sysimagepath -t$t"
    else
        juliacmd="$juliapath -J $sysimagepath -p$(($w-1)) -t$t"
    fi

    for n in "${ns[@]}"; do
        for uvc in "${unique_vals_count[@]}"; do
            for chunksize in "${chunksizes[@]}"; do
                if [ "$uvc" == "1000" ]; then
                    runcmd "$juliacmd ${s}dtable_basic.jl $n $chunksize $uvc $ncols"
                fi
                runcmd "$juliacmd ${s}dtable_groupby.jl $n $chunksize $uvc $ncols"
                runcmd "$juliacmd ${s}dtable_grouped_reduce.jl $n $chunksize $uvc $ncols"
                runcmd "$juliacmd ${s}dtable_innerjoin_unique.jl $n $chunksize $uvc $ncols"

                runcmd "$juliacmd ${s}dtable_full_scenario_generate_data.jl $n $chunksize $uvc $ncols"
                runcmd "$juliacmd ${s}dtable_full_scenario_load_benchmark.jl $n $chunksize $uvc $ncols"
                runcmd "$juliacmd ${s}dtable_full_scenario_stages_benchmark.jl $n $chunksize $uvc $ncols"
                rm -r data
            done
        done
    done
}


workers="1"
threads=('2' '4' '8' '16')
chunksizes=('10000000' '25000000')
ns=('10000000' '100000000' '500000000' '1000000000')
unique_vals_count=('1000' '10000')
ncols="4"
w=$workers


for t in "${threads[@]}"; d
    benchmarkloop
done

workers=('4' '8' '12')
threads="4"
chunksizes=('10000000')
ns=('10000000' '100000000' '500000000' '1000000000' '2000000000')
unique_vals_count=('1000' '10000')
t=$threads


for w in "${workers[@]}"; do
    benchmarkloop
done
