#!/bin/bash

docker-clean() {
  docker ps -a | grep 'Exit' | awk '{print $1}' | while read -r id ;do
    docker rm $id
  done
  docker images | grep '^<none>' | awk 'BEGIN { FS = "[ \t]+" } { print $3 }'  | while read -r id ; do
    docker rmi $id
  done
}

docker-clean
