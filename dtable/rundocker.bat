docker build -t dtable .
SET parent=%~dp0..\
docker run --rm -v %parent%:/home dtable
