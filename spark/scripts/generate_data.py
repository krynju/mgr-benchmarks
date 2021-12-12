import math, time
import os
import pandas as pd
import timeit
import sys
import numpy as np

n = int(sys.argv[1])
unique_values = int(sys.argv[2])
ncolumns = int(sys.argv[3])
max_chunksize = 10000000

import concurrent.futures
if __name__ == '__main__':

    tablesize = 4 * ncolumns * n / 1_000_000
    print("@@@ TABLESIZE:       {} MB".format(tablesize))
    nchunks = int((n+max_chunksize-1)/max_chunksize)
    os.mkdir("data")

    def gen_and_save(idx):
        df = pd.DataFrame(np.random.randint(0, unique_values-1, size=(max_chunksize, ncolumns)),columns=['a1', 'a2', 'a3', 'a4'])
        df.to_csv(f'data/datapart_{idx}.csv', index=False)

    with concurrent.futures.ProcessPoolExecutor(max_workers=10) as executor:
        for idx in range(nchunks):
            executor.submit(gen_and_save, idx)

