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
    client = Client(n_workers=workers, threads_per_worker=threads, processes=False, memory_limit='32GB')
    client.restart()


    x = da.random.randint(0, unique_values, size=(int(n), ncolumns), chunks=(max_chunksize, ncolumns))
    tablesize = 4 * ncolumns * n / 1_000_000
    print("@@@ TABLESIZE:       {} MB".format(tablesize))

    if not os.path.exists('results'):
        os.mkdir('results')

    filename = 'results/dask_bench' + str(round(time.time() * 1000)) + '.csv'
    file = open(filename, 'w')
    file.write('tech,type,n,chunksize,unique_vals,ncolumns,time,gctime,memory,allocs,workers,threads\n')


    def runb(type, f):
        t = timeit.timeit(stmt=f, setup='gc.enable()', number=1)
        file.write('{},{},{},{},{},{},{},{},{},{},{},{}\n'.format('dask',type, n, max_chunksize,unique_values,ncolumns, t*1e9, 0, 0, 0, workers, threads))
        file.flush()
        print('@@@ DONE:            '+ type + '\n')

    df = dd.from_dask_array(x, columns=['a1','a2','a3','a4']).persist()
    wait(df)
    x = None

    d2 = pd.DataFrame({
        "a1": np.arange(0, unique_values, dtype=np.int32),
        "a5": np.arange(0, unique_values, dtype=np.int32)
    })
    runb('innerjoin_r_unique', lambda : df.join(d2.set_index('a1'), on='a1').compute())

    file.close()
