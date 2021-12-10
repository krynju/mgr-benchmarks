docker build -t dtable .
SET parent=%~dp0..\
docker run -v %parent%:/home dtable
