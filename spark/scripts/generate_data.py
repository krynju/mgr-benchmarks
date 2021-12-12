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

if __name__ == '__main__':

    tablesize = 4 * ncolumns * n / 1_000_000
    print("@@@ TABLESIZE:       {} MB".format(tablesize))
    df = pd.DataFrame(np.random.randint(0, unique_values-1, size=(n, ncolumns)),columns=['a1', 'a2', 'a3', 'a4'])
    nchunks = int((n+max_chunksize-1)/max_chunksize)
    os.mkdir("data")

    for idx, chunk in enumerate(np.array_split(df, nchunks)):
        chunk.to_csv(f'data/datapart_{idx}.csv', index=False)
