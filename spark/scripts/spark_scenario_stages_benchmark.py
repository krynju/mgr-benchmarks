from pyspark.sql import SparkSession
from pyspark.sql.types import IntegerType, StructType
from pyspark.sql.functions import variance, count, mean, min, max, col, countDistinct
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
    print('@@@ DONE:            '+ type + '\n')
    file.write('{},{},{},{},{},{},{},{},{},{},{},{}\n'.format('spark',type, n, max_chunksize,unique_values,ncolumns, t*1e9, 0, 0, 0, workers, threads))
    file.flush()


npartitions = int((n+max_chunksize-1)/max_chunksize)

def load_df():
    df = spark.read.format("csv").options(header='True').schema(schema).load(os.getcwd() + '/data').repartition(npartitions)
    df.count()
    return df


runb('scenario_table_load', lambda : load_df())

with time_usage("load df2"):
    df = spark.read.format("csv").options(header='True').schema(schema).load(os.getcwd() + '/data').repartition(npartitions)
    df.count()

def scenario_full_table_statistics(d):
    d.select(
        *[mean(c) for c in d.columns],
        *[variance(c) for c in d.columns],
        *[min(c) for c in d.columns],
        *[max(c) for c in d.columns]
    ).show()


##########

def scenario_count_unique_a1(d):
    df.groupBy("a1").count().show()


#######################
# rowwise sum and reduce

def scenario_rowwise_sum_and_mean_reduce(d):
    d.select(mean(col("a1") + col("a2") + col("a3") + col("a4"))).show()


def scenario_grouped_a1_statistics(d):
    d.groupby('a1').agg(
        *[mean(c) for c in d.columns],
        *[variance(c) for c in d.columns],
        *[min(c) for c in d.columns],
        *[max(c) for c in d.columns]
    ).show()


runb('scenario_full_table_statistics', lambda : scenario_full_table_statistics(df))
runb('scenario_count_unique_a1', lambda : scenario_count_unique_a1(df))
runb('scenario_rowwise_sum_and_mean_reduce', lambda : scenario_rowwise_sum_and_mean_reduce(df))
runb('scenario_grouped_a1_statistics', lambda: scenario_grouped_a1_statistics(df))


file.close()