docker build -t dask .
docker run --rm -v ~/mgr-benchmarks/:/home dask
