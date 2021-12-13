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


n = int(sys.argv[1])
max_chunksize = int(sys.argv[2])
unique_values = int(sys.argv[3])
ncolumns = int(sys.argv[4])

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
file.write('tech,type,n,chunksize,unique_vals,ncolumns,time,gctime,memory,allocs\n')
file.flush()

def runb(type, f):
    t = timeit.timeit(stmt=f, setup='gc.enable()', number=1)
    file.write('{},{},{},{},{},{},{},{},{},{}\n'.format('spark',type, n, max_chunksize,unique_values,ncolumns, t*1e9, 0, 0, 0))
    file.flush()
    print('@@@ DONE:            '+ type + '\n')

npartitions = int((n+max_chunksize-1)/max_chunksize)

with time_usage("load df2"):
    df = spark.read.format("csv").options(header='True').schema(schema).load(os.getcwd() + '/data').repartition(npartitions)
    df.count()

runb('count', lambda : df.select(count('a1')).collect())
runb('count', lambda : df.count())
runb('increment_map', lambda : df.rdd.map(lambda x: x['a1'] + 1).count())
runb('filter_half', lambda : df[df.a1 < unique_values/2].count())
runb('reduce_var_single', lambda : df.select(variance('a1')).collect())
runb('reduce_var_all', lambda : df.select(variance('a1'), variance('a2'), variance('a3'), variance('a4')).collect())
runb('groupby_single_col', lambda : df.groupBy('a1').count().collect())
runb('grouped_reduce_mean_singlecol', lambda : df.groupBy('a1').mean('a2').collect())
runb('grouped_reduce_mean_allcols', lambda : df.groupBy('a1').mean().collect())

file.close()