docker build -t dask .
SET parent=%~dp0..\
docker run -v %parent%:/home dask
