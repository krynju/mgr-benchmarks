docker build -t juliabuild .
SET parent=%~dp0
docker run --rm -v %parent%:/tmp/juliabuild juliabuild
