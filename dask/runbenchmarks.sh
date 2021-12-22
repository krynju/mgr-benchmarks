s="scripts/"

runcmd() {
    echo "@@@ STARTING CONFIG: $1"
    eval $1
    sleep 2
    echo "@@@ ENDING CONFIG:   $1"
}

trap "exit" INT

benchmarkloop() {
    for n in "${ns[@]}"; do
        for chunksize in "${chunksizes[@]}"; do
            for uvc in "${unique_vals_count[@]}"; do
                if [ "$uvc" == "1000" ]; then
                    runcmd "python ${s}daskb_basic.py $w $t $n $chunksize $uvc $ncols"
                fi
                runcmd "python ${s}daskb_groupby.py $w $t $n $chunksize $uvc $ncols"
                runcmd "python ${s}daskb_join.py $w $t $n $chunksize $uvc $ncols"
            done
        done
    done

    for n in "${ns[@]}"; do
        for uvc in "${unique_vals_count[@]}"; do
            for chunksize in "${chunksizes[@]}"; do
                runcmd "python ${s}daskb_scenario_generate_data.py $w $t $n $chunksize $uvc $ncols"
                runcmd "python ${s}daskb_scenario_stages_benchmark.py $w $t $n $chunksize $uvc $ncols"
                rm -r data
            done
        done
    done
}

# ns=('10000000')

# threaded
workers="1"
threads=('8' '16' '32')
chunksizes=('10000000' '25000000')
ns=('10000000' '100000000' '500000000' '1000000000')
unique_vals_count=('1000' '10000')
ncols="4"

for t in "${threads[@]}"; do
    w=$workers
    benchmarkloop
done

# with workers
workers=('2' '4' '8' '12')
threads="4"
chunksizes=('10000000' '25000000')
# ns=('10000000' '100000000' '500000000' '1000000000' '2000000000' '3000000000')
ns=('10000000' '100000000' '500000000' '1000000000')
unique_vals_count=('1000')

for w in "${workers[@]}"; do
    t=$threads
    benchmarkloop
done

# with workers bigger uvc
# ns=('10000000' '100000000' '500000000' '1000000000' '2000000000')
ns=('10000000' '100000000' '500000000' '1000000000')
unique_vals_count=('10000')
for w in "${workers[@]}"; do
    t=$threads
    benchmarkloop
done