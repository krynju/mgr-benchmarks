# https://cloud.google.com/community/tutorials/docker-compose-on-container-optimized-os
# docker-compose up --scale spark-worker=4

w=$1
docker-compose --env-file envs/worker$w.env up --scale spark-worker=$w