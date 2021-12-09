threads=16
workers=1

# chunksizes=('1000000')
# ns=('100000')
# unique_vals_count=('1000')

chunksizes=('1000000' '10000000')
ns=('1000000' '10000000' '100000000' '500000000' '1000000000')
unique_vals_count=('1000' '10000')
ncols="4"

s="scripts/"

if [[ $workers -eq 1 ]]; then
    juliacmd="julia -t$threads"
    pythoncmd="python ${s}daskb.py 1 $threads"
else
    juliacmd="julia -p$(($workers-1)) -t$threads"
    pythoncmd="python ${s}daskb.py $workers $threads"
fi

runcmd() {
    echo "starting $1"
    eval $1
    sleep 2
    echo "done $1"
}

source python_prep.sh
source venv/bin/activate

for n in "${ns[@]}"; do
    for uvc in "${unique_vals_count[@]}"; do
        for chunksize in "${chunksizes[@]}"; do
            runcmd "$pythoncmd $n $chunksize $uvc $ncols"
        done
    done
done
