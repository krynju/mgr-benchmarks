from pyspark.sql import SparkSession
import random
spark = SparkSession.builder.master('spark://spark:7077').getOrCreate()

NUM_SAMPLES = 1000

def inside(p):
    
    x, y = random.random(), random.random()
    return x*x + y*y < 1

count = spark.sparkContext.parallelize(range(0, NUM_SAMPLES)) \
             .filter(inside).count()
print("Pi is roughly %f" % (4.0 * count / NUM_SAMPLES))