from pyspark.sql import SparkSession
from pyspark.sql.types import IntegerType, StructType
from pyspark.sql.functions import variance, count, mean
from contextlib import contextmanager
import random
import pandas as pd
import numpy as np
import time
import logging
import sys
import os
import timeit

workers = int(sys.argv[1])
threads = int(sys.argv[2])
n = int(sys.argv[3])
max_chunksize = int(sys.argv[4])
unique_values = int(sys.argv[5])
ncolumns = int(sys.argv[6])

spark = SparkSession \
    .builder \
    .appName("basic_spark_benchmark") \
    .config('spark.sql.shuffle.partitions', unique_values) \
    .master('spark://spark:7077') \
    .getOrCreate()

spark.sparkContext.setLogLevel('ERROR')

@contextmanager
def time_usage(name=""):
    start = time.time_ns()
    yield
    end = time.time_ns()
    elapsed_seconds = float("%.4f" % ((end - start)/1e9))
    print('%s: elapsed seconds: %s', name, elapsed_seconds)

schema = StructType() \
      .add("a1",IntegerType(),True) \
      .add("a2",IntegerType(),True) \
      .add("a3",IntegerType(),True) \
      .add("a4",IntegerType(),True)

rpath = 'results'
if not os.path.exists(rpath):
    os.mkdir(rpath)

filename = rpath + '/spark_bench' + str(round(time.time() * 1000)) + '.csv'
file = open(filename, 'w')
file.write('tech,type,n,chunksize,unique_vals,ncolumns,time,gctime,memory,allocs,workers,threads\n')
file.flush()

def runb(type, f):
    print('@@@ STARTED:         '+ type + '\n')
    t = timeit.timeit(stmt=f, setup='gc.enable()', number=1)
    file.write('{},{},{},{},{},{},{},{},{},{},{},{}\n'.format('spark',type, n, max_chunksize,unique_values,ncolumns, t*1e9, 0, 0, 0, workers, threads))
    file.flush()
    print('@@@ DONE:            '+ type + '\n')

npartitions = int((n+max_chunksize-1)/max_chunksize)

with time_usage("load df2"):
    df = spark.read.format("csv").options(header='True').schema(schema).load(os.getcwd() + '/data').repartition(npartitions)
    df.count()

runb('count', lambda : df.select(count('a1')).collect())
runb('count', lambda : df.count())

############## benchmarks
d = {
    "a1": np.arange(0, unique_values, dtype=np.int32),
    "a5": np.arange(0, unique_values, dtype=np.int32)
}

df2 = spark.createDataFrame(pd.DataFrame(d))

runb('innerjoin_r_unique', lambda: df.join(df2, df.a1 ==  df2.a1, "inner").count())

file.close()