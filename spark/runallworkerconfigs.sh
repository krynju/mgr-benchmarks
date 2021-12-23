workers=('4' '8' '12')


for w in "${workers[@]}"; do
    bash runspark.sh $w &>/dev/null &
    sleep 5
    until [ ! -z `docker ps -q -f "status=running" --no-trunc | grep $(docker-compose ps -q spark)` ]; do
        echo "No, it's not running."
        sleep 1;
    done;
    echo "running"

    sleep 10
    bash rundocker.sh $w
done
docker kill spark_spark_1
