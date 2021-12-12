from pyspark.sql import SparkSession
from pyspark.sql.types import IntegerType, StructType

#Create PySpark SparkSession
from contextlib import contextmanager
import random
import pandas as pd
import numpy as np
import time
import logging

spark = SparkSession \
    .builder \
    .appName("basic_spark_benchmark") \
    .master('spark://spark:7077') \
    .getOrCreate()


# n = int(sys.argv[3])
# max_chunksize = int(sys.argv[4])
# unique_values = int(sys.argv[5])
# ncolumns = int(sys.argv[6])

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

with time_usage("load df2"):
    df2 = spark.read.format("csv").options(header='True').schema(schema).load("/home/sparkbenchmarks/data")


with time_usage("elo"):
    df2.rdd.map(lambda x: x['a1'] + 1).collect()
