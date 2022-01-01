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
from datetime import datetime

workers = int(sys.argv[1])
threads = int(sys.argv[2])
n = int(sys.argv[3])
max_chunksize = int(sys.argv[4])
unique_values = int(sys.argv[5])
ncolumns = int(sys.argv[6])

pp = workers > 1

if __name__ == '__main__':
    with Client(n_workers=workers, threads_per_worker=threads, processes=pp) as client:



        x = da.random.randint(1, unique_values+1, size=(int(n), ncolumns), chunks=(max_chunksize, ncolumns), dtype=np.int32)
        tablesize = 4 * ncolumns * n / 1_000_000
        print("@@@ TABLESIZE:       {} MB".format(tablesize))

        if not os.path.exists('results'):
            os.mkdir('results')

        filename = 'results/dask_bench' + str(round(time.time() * 1000)) + '.csv'
        with open(filename, 'a') as file:
            file.write('tech,type,n,chunksize,unique_vals,ncolumns,time,gctime,memory,allocs,workers,threads\n')


        def runb(type, f):
            print('@@@ STARTED:         {} {}\n'.format(type, datetime.now()))
            sys.stdout.flush()
            t = timeit.timeit(stmt=f, setup='gc.enable()', number=1)
            with open(filename, 'a') as file:
                file.write('{},{},{},{},{},{},{},{},{},{},{},{}\n'.format('dask',type, n, max_chunksize,unique_values,ncolumns, t*1e9, 0, 0, 0, workers, threads))
                file.flush()
            print('@@@ DONE:            {} {}\n'.format(type, datetime.now()))
            sys.stdout.flush()

        df = dd.from_dask_array(x, columns=['a1','a2','a3','a4']).persist()
        wait(df)
        x = None

        runb('groupby_single_col', lambda : wait(df.shuffle('a1', shuffle='tasks', npartitions=unique_values).persist()))

        runb('grouped_reduce_mean_singlecol', lambda : df.groupby('a1')['a2'].mean().compute())
        runb('grouped_reduce_mean_allcols', lambda : df.groupby('a1').mean().compute())

        sys.stdout.flush()
        if sys.platform == 'win32':
            client.run(os.system('taskkill /F /PID %d' % os.getpid()))
        else:
            client.run(os.system('kill -9 %d' % os.getpid()))

        try:
            client.shutdown()
        except:
            if sys.platform == 'win32':
                os.system('taskkill /F /PID %d' % os.getpid())
            else:
                print("trying to kill")
                os.system('kill -9 %d' % os.getpid())
