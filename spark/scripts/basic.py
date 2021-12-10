from pyspark import SparkContext, SparkConf
import random
import pandas as pd
import numpy as np

conf = SparkConf().setAppName('basic_spark_benchmark').setMaster('spark://spark:7077')
sc = SparkContext(conf=conf)

# n = int(sys.argv[3])
# max_chunksize = int(sys.argv[4])
# unique_values = int(sys.argv[5])
# ncolumns = int(sys.argv[6])


n = 10000000
max_chunksize = 1000000
unique_values = 1000
ncolumns = 4

distData = sc.parallelize( \
    pd.DataFrame(
        np.random.randint(0, unique_values, size=(n, ncolumns)), \
        columns=['a1', 'a2', 'a3', 'a4']), \
    int((n+max_chunksize-1)/max_chunksize) \
    )

print('Hello World')