import math, time
import os
from dask.distributed import Client, wait
from distributed.client import default_client
import pandas as pd
import numpy as np
import timeit
import sys
import dask.array as da
import dask.dataframe as dd

workers = int(sys.argv[1])
threads = int(sys.argv[2])
n = int(sys.argv[3])
max_chunksize = int(sys.argv[4])
unique_values = int(sys.argv[5])
ncolumns = int(sys.argv[6])

if __name__ == '__main__':
    client = Client(n_workers=workers, threads_per_worker=threads, processes=False)
    client.restart()


    x = da.random.randint(1, unique_values+1, size=(int(n), ncolumns), chunks=(max_chunksize, ncolumns), dtype=np.int32)
    tablesize = 4 * ncolumns * n / 1_000_000
    print("@@@ TABLESIZE:       {} MB".format(tablesize))

    if not os.path.exists('results'):
        os.mkdir('results')

    filename = 'results/dask_bench' + str(round(time.time() * 1000)) + '.csv'
    file = open(filename, 'w')
    file.write('tech,type,n,chunksize,unique_vals,ncolumns,time,gctime,memory,allocs,workers,threads\n')


    def runb(type, f):
        print('@@@ STARTED:         '+ type + '\n')
        t = timeit.timeit(stmt=f, setup='gc.enable()', number=1)
        file.write('{},{},{},{},{},{},{},{},{},{},{},{}\n'.format('dask',type, n, max_chunksize,unique_values,ncolumns, t*1e9, 0, 0, 0, workers, threads))
        file.flush()
        print('@@@ DONE:            '+ type + '\n')

    df = dd.from_dask_array(x, columns=['a1','a2','a3','a4']).persist()
    wait(df)
    x = None


    runb('increment_map', lambda : wait((df['a1'] + 1).persist()))

    runb('filter_half', lambda : df[df['a1'] < unique_values /2].compute())

    runb('reduce_var_all', lambda : df.var().compute())

    runb('reduce_var_single', lambda : df['a1'].var().compute())

    file.close()