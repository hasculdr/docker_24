#!/bin/bash 

container_db_test=$(docker ps --quiet --filter "name=grafana_db")
container_app_test=$(docker ps --quiet --filter "name=grafana_app")

if [[ ! -z $container_app_test ]]; then
  echo "Останавливаю контейнер"|tr '\n' ' '
  docker stop grafana_app;
fi

if [[ ! -z $container_db_test ]]; then
  echo "Останавливаю контейнер"|tr '\n' ' '
  docker stop grafana_db;
fi

ntwrk_int_test=$(docker network ls --quiet --filter "name=grafana_internal")
ntwrk_ext_test=$(docker network ls --quiet --filter "name=grafana_external")

if [[ ! -z $ntwrk_int_test ]]; then
  echo "Удаляю сеть"|tr '\n' ' '
  docker network rm grafana_internal;
fi

if [[ ! -z $ntwrk_ext_test ]]; then
  echo "Удаляю сеть"|tr '\n' ' '
  docker network rm grafana_external;
fi
