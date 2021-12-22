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
from daskb_scenario_stages import *

workers = int(sys.argv[1])
threads = int(sys.argv[2])
n = int(sys.argv[3])
max_chunksize = int(sys.argv[4])
unique_values = int(sys.argv[5])
ncolumns = int(sys.argv[6])

# workers = 4
# threads = 4
# n = int(1e7)
# max_chunksize = int(1e7)
# unique_values = int(1e3)
# ncolumns = int(4)

if __name__ == '__main__':
    client = Client(n_workers=workers, threads_per_worker=threads, processes=False)
    client.restart()

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

    npartitions = int((n+max_chunksize-1)/max_chunksize)

    runb('scenario_table_load', lambda : scenario_table_load(dd, np, npartitions))

    df = scenario_table_load(dd, np, npartitions)

    runb('scenario_full_table_statistics', lambda : scenario_full_table_statistics(df))

    runb('scenario_count_unique_a1', lambda : scenario_count_unique_a1(df))

    runb('scenario_rowwise_sum_and_mean_reduce', lambda : scenario_rowwise_sum_and_mean_reduce(df))

    runb('scenario_grouped_a1_statistics', lambda: scenario_grouped_a1_statistics(df))

    file.close()
