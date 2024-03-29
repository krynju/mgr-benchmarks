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
                runcmd "python ${s}daskb_scenario_generate_data.py $w $t $n $chunksize $uvc $ncols"
                runcmd "python ${s}daskb_scenario_stages_benchmark.py $w $t $n $chunksize $uvc $ncols"
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

for t in "${threads[@]}"; do
    benchmarkloop
done



workers=('4' '8')
threads="4"
chunksizes=('10000000')
ns=('10000000' '100000000' '500000000' '1000000000' '2000000000')
unique_vals_count=('1000' '10000')
t=$threads

for w in "${workers[@]}"; do
    benchmarkloop
done
