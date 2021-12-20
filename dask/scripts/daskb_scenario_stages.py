
def scenario_table_load(dd, np, nparts):
    return dd.from_pandas(dd.read_csv('data/datapart_*.csv', dtype=np.int32).compute(scheduler='threads'), nparts).persist(scheduler='distributed')

def scenario_full_table_statistics(d):
    _max = d.max().compute()
    _min = d.min().compute()
    _var = d.var().compute()
    _mean = d.mean().compute()

##########

def scenario_count_unique_a1(d):
    return d['a1'].value_counts().compute()


#######################
# rowwise sum and reduce

def scenario_rowwise_sum_and_mean_reduce(d):
    d.apply(sum, axis=1, meta=(None, 'int32')).mean().compute()


def scenario_grouped_a1_statistics(d):
    g = d.groupby('a1')
    _max = g.max().compute()
    _min = g.min().compute()
    _var = g.var().compute()
    _mean = g.mean().compute()
