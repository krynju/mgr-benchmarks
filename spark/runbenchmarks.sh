python -m pip install -r /home/sparkbenchmarks/requirements.txt &>/dev/null

chunksizes=('1000000')
ns=('10000000')
unique_vals_count=('1000')

# chunksizes=('1000000' '10000000')
# ns=('1000000' '10000000' '100000000' '500000000' '1000000000')
# unique_vals_count=('1000' '10000')
ncols="4"

s="scripts/"

pythoncmd="python /home/sparkbenchmarks/generate_data.py"

runcmd() {
    echo "@@@ STARTING CONFIG: $1"
    eval $1
    sleep 2
    echo "@@@ ENDING CONFIG:   $1"
}

for n in "${ns[@]}"; do
    for uvc in "${unique_vals_count[@]}"; do
        rm -r /home/sparkbenchmarks/data
        runcmd "$pythoncmd $n $uvc $ncols"
        # for chunksize in "${chunksizes[@]}"; do
        spark-submit /home/sparkbenchmarks/scripts/basic.py "$pythoncmd $n $uvc $ncols"
        # done
    done
done

