docker build -t juliabuild .
docker run -v /home/mgr-benchmarks/_julia_builder/:/tmp/juliabuild juliabuild