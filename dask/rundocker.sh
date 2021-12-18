docker build -t dask .
docker run -v --rm ./../:/home dask
