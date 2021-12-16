threads=16
workers=1

chunksizes=('1000000')
ns=('100000')
unique_vals_count=('1000')

# chunksizes=('1000000' '10000000')
# ns=('1000000' '10000000' '100000000' '500000000' '1000000000')
# ns=('500000000' '1000000000')
# unique_vals_count=('1000' '10000')
ncols="4"

s="scripts/"

if [[ $workers -eq 1 ]]; then
    juliacmd="julia -t$threads"
else
    juliacmd="julia -p$(($workers-1)) -t$threads"
fi

runcmd() {
    echo "@@@ STARTING CONFIG: $1"
    eval $1
    sleep 2
    echo "@@@ ENDING CONFIG:   $1"
}

eval "julia -t4 init.jl"

trap "exit" INT
for n in "${ns[@]}"; do
    for uvc in "${unique_vals_count[@]}"; do
        for chunksize in "${chunksizes[@]}"; do
            runcmd "$juliacmd ${s}dtable_basic.jl $n $chunksize $uvc $ncols"
            runcmd "$juliacmd ${s}dtable_groupby.jl $n $chunksize $uvc $ncols"
            runcmd "$juliacmd ${s}dtable_grouped_reduce.jl $n $chunksize $uvc $ncols"
            # runcmd "$juliacmd ${s}dtable_innerjoin_small.jl $n $chunksize $uvc $ncols"
        done
    done
done
