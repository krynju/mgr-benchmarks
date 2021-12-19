cd /home/spark
python -m pip install -r requirements.txt &>/dev/null

workers="4"
threads="4"

chunksizes=('10000000')
ns=('10000000' '100000000' '500000000' '1000000000')
unique_vals_count=('1000' '10000')
ncols="4"

pythoncmd="python "

runcmd() {
    echo "@@@ STARTING CONFIG: $1"
    eval $1
    sleep 2
    echo "@@@ ENDING CONFIG:   $1"
}



for n in "${ns[@]}"; do
    for uvc in "${unique_vals_count[@]}"; do
        rm -r data
        runcmd "python scripts/generate_data.py $n $uvc $ncols"
        for chunksize in "${chunksizes[@]}"; do
            runcmd "spark-submit scripts/basic.py $workers $threads $n $chunksize $uvc $ncols"
        done
    done
done

