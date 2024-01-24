#!/usr/bin/env bash
panic() {
  echo $1
  exit 1
}

podman build -f ./deployment/linuxfr.org/Dockerfile -t linuxfr/linuxfr.org . \
    || panic "Cannot build linuxfr.org"

podman build -f ./deployment/linuxfr-board/Dockerfile -t linuxfr/linuxfr-board ./deployment/linuxfr-board \
    || panic "Cannot build linuxfr-board"

podman build -f ./deployment/linuxfr-img/Dockerfile -t linuxfr/linuxfr-img ./deployment/linuxfr-img \
    || panic "Cannot build linuxfr-img"

podman build -f ./deployment/database/Dockerfile -t linuxfr/database ./deployment/database \
    || panic "Cannot build linuxfr-img"