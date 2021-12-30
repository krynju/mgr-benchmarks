docker build -t dask .
SET parent=%~dp0..\
docker run --rm -v %parent%:/home dask
