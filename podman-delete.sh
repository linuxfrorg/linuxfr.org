#!/usr/bin/env bash

### linuxfr containers

podman pod stop linuxfr \
    || echo "Cannot stop pod"

podman pod rm linuxfr \
    || echo "Cannot remove pod"

### linuxfr volumes

podman volume rm linuxfr-data-database \
    || echo "Cannot remove volume linuxfr-data-database"

podman volume rm linuxfr-data-redis \
    || echo "Cannot remove volume linuxfr-data-redis"

podman volume rm linuxfr-data-uploads \
    || echo "Cannot remove volume linuxfr-data-uploads"

podman volume rm linuxfr-cache-img \
    || echo "Cannot remove volume linuxfr-cache-img"


