# https://cloud.google.com/community/tutorials/docker-compose-on-container-optimized-os
# docker-compose up --scale spark-worker=4
w=$1
#docker-compose --env-file envs/worker$w.env up --scale spark-worker=$w
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD:$PWD" \
    -w="$PWD" \
    docker/compose --env-file envs/worker$w.env up --scale spark-worker=$w
