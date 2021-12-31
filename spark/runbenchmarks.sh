cd /home/spark
python -m pip install -r requirements.txt &>/dev/null

workers=$1
threads="4"

runcmd() {
    echo "@@@ STARTING CONFIG: $1"
    eval $1
    sleep 2
    echo "@@@ ENDING CONFIG:   $1"
}

benchmarkloop() {
    for n in "${ns[@]}"; do
        for chunksize in "${chunksizes[@]}"; do
            for uvc in "${unique_vals_count[@]}"; do
                runcmd "python scripts/generate_data.py $workers $threads $n $chunksize $uvc $ncols"
                if [ "$uvc" == "1000" ]; then
                    runcmd "spark-submit scripts/spark_basic.py $workers $threads $n $chunksize $uvc $ncols"
                fi
                runcmd "spark-submit scripts/spark_groupby.py $workers $threads $n $chunksize $uvc $ncols"
                runcmd "spark-submit scripts/spark_join.py $workers $threads $n $chunksize $uvc $ncols"
                runcmd "spark-submit scripts/spark_scenario_stages_benchmark.py $workers $threads $n $chunksize $uvc $ncols"
                rm -r data
            done
        done
    done
}


chunksizes=('10000000')
ns=('10000000' '100000000' '500000000' '1000000000' '2000000000' '3000000000')
unique_vals_count=('1000')
ncols="4"

if [ "$workers" == "4" ]; then
    ns=('2000000000' '3000000000')
fi

benchmarkloop


ns=('10000000' '100000000' '500000000' '1000000000' '2000000000')
unique_vals_count=('10000')

if [ "$workers" == "4" ]; then
    ns=('2000000000')
fi

benchmarkloop