import math, time
import os
import pandas as pd
import timeit
import sys
import numpy as np

workers = int(sys.argv[1])
threads = int(sys.argv[2])
n = int(sys.argv[3])
max_chunksize = int(sys.argv[4])
unique_values = int(sys.argv[5])
ncolumns = int(sys.argv[6])

def gen_and_save(idx):
    df = pd.DataFrame(np.random.randint(1, unique_values+1, size=(max_chunksize, ncolumns), dtype=np.int32), columns=['a1', 'a2', 'a3', 'a4'])
    df.to_csv(f'data/datapart_{idx}.csv', index=False)

import concurrent.futures
if __name__ == '__main__':
    tablesize = 4 * ncolumns * n / 1_000_000
    print("@@@ TABLESIZE:       {} MB".format(tablesize))
    nchunks = int((n+max_chunksize-1)/max_chunksize)
    os.mkdir("data")

    with concurrent.futures.ProcessPoolExecutor(max_workers=10) as executor:
        for idx in range(nchunks):
            executor.submit(gen_and_save, idx)
