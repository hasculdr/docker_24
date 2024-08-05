#!/bin/bash 

ntwrk_int_test=$(docker network ls --quiet --filter "name=grafana_internal")
ntwrk_ext_test=$(docker network ls --quiet --filter "name=grafana_external")

if [[ -z $ntwrk_int_test ]]; then
  echo "Создаю сеть для связи с базой данных"|tr '\n' ' '
  docker network create --subnet 192.168.200.0/29 --gateway 192.168.200.1 grafana_internal;
fi

if [[ -z $ntwrk_ext_test ]]; then
  echo "Создаю сеть для связи с приложением"|tr '\n' ' '
  docker network create --subnet 192.168.201.0/30 --gateway 192.168.201.1 grafana_external;
fi

container_db_test=$(docker ps -a --quiet --filter "name=grafana_db")
container_app_test=$(docker ps -a --quiet --filter "name=grafana_app")


if [[ -z $container_db_test ]]; then
  echo "Создаю и запускаю контейнер с базой данных"|tr '\n' ' '
  docker run -d --rm --name=grafana_db \
    --net grafana_internal --ip 192.168.200.3 \
    -e POSTGRES_USER=grafana \
    -e POSTGRES_PASSWORD=mysecretpassword \
    -e POSTGRES_DB=grafana \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    --volume ./database:/var/lib/postgresql/data/pgdata:rw \
    postgres:16.3-alpine3.20
fi

if [[ -z $container_app_test ]]; then
  echo "Создаю контейнер с приложением"|tr '\n' ' '
  docker create --rm -p 3000:3000 --name=grafana_app \
    --net grafana_external --ip 192.168.201.2 \
    --user "0" \
    --volume ./data:/var/lib/grafana:rw \
    -e "GF_SERVER_ROOT_URL=http://my.grafana.server/" \
    -e "GF_SERVER_HTTP_ADDR=192.168.201.2" \
    -e "GF_DATABASE_TYPE=postgres" \
    -e "GF_DATABASE_NAME=grafana" \
    -e "GF_DATABASE_USER=grafana" \
    -e "GF_DATABASE_HOST=192.168.200.3" \
    -e "GF_DATABASE_PASSWORD=mysecretpassword" \
    grafana/grafana-oss:11.1.3;
  echo "Добавляю к нему сеть для связи с базой данных"
  docker network connect --ip 192.168.200.2 grafana_internal grafana_app;
  echo "Запускаю контейнер с приложением"|tr '\n' ' '
  docker start grafana_app;
  docker ps --filter "name=grafana";
fi
