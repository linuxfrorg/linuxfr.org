#!/usr/bin/env bash
panic() {
  echo $1
  exit 1
}

podman pod create --replace --name=linuxfr \
    --publish "8080:8080" \
    --publish "8081:8081" \
    --publish "3306:3306" \
    || panic "Cannot create pod"

#TODO add --cap-drop=all
podman run --name linuxfrdatabase \
    --uts=private --hostname linuxfrdatabase \
    --pod linuxfr \
    --pull missing --detach \
    --read-only \
    --env-file=deployment/podman.env \
    --mount "type=volume,src=linuxfr-data-database,dst=/var/lib/mysql" \
    linuxfr/database \
    || panic "Cannot run linuxfrdatabase"

#TODO add --cap-drop=all
podman run --name linuxfrredis \
    --uts=private --hostname linuxfrredis \
    --pod linuxfr \
    --pull missing --detach \
    --read-only \
    --mount "type=volume,src=linuxfr-data-redis,dst=/data" \
    redis:5 \
    || panic "Cannot run linuxfrredis"

podman run --name linuxfrboard \
    --uts=private --hostname linuxfboard \
    --pod linuxfr \
    --pull missing --detach \
    --cap-drop=all --read-only \
    --env-file=deployment/podman.env \
    linuxfr/linuxfr-board \
    || panic "Cannot run linuxfrboard"

podman run --name linuxfrimg \
    --uts=private --hostname linuxfrimg \
    --pod linuxfr \
    --pull missing --detach \
    --cap-drop=all --read-only \
    --env-file=deployment/podman.env \
    --mount "type=volume,src=linuxfr-cache-img,dst=/linuxfr-img/cache" \
    linuxfr/linuxfr-img \
    || panic "Cannot run linuxfrimg"

#todo --read-only
podman run --name linuxfrorg \
    --uts=private --hostname linuxfrorg \
    --pod linuxfr \
    --pull missing --detach \
    --cap-drop=all \
    --env-file=deployment/podman.env \
    -v "./app:/linuxfr.org/app:ro" \
    -v "./db:/linuxfr.org/db:ro" \
    -v "./public:/linuxfr.org/public:ro" \
    -v "./test:/linuxfr/test:ro" \
    --mount "type=volume,src=linuxfr-data-uploads,dst=/var/linuxfr/uploads" \
    linuxfr/linuxfr.org \
    || panic "Cannot run linuxfrorg"

#todo --read-only
podman run --name linuxfrorgsetup \
    --uts=private --hostname linuxfrorgsetup \
    --pod linuxfr \
    --pull missing --detach \
    --cap-drop=all \
    --env-file=deployment/podman.env \
    -v "./app:/linuxfr.org/app:ro" \
    -v "./db:/linuxfr.org/db:ro" \
    -v "./public:/linuxfr.org/public:ro" \
    -v "./test:/linuxfr/test:ro" \
    --mount "type=volume,src=linuxfr-data-uploads,dst=/var/linuxfr/uploads" \
    linuxfr/linuxfr.org \
    bin/rails db:setup \
    || panic "Cannot run linuxfrorg"


#todo --cap-drop=all --read-only
podman run --name linuxfrnginx \
    --uts=private --hostname linuxfrnginx \
    --pod linuxfr \
    --pull missing --detach \
    -e "NGINX_PORT=8080" \
    --env-file=deployment/podman.env \
    -v "./deployment/nginx/templates:/etc/nginx/templates:ro" \
    -v "./public/fonts:/var/linuxfr/fonts:ro" \
    --mount "type=volume,src=linuxfr-data-uploads,dst=/var/linuxfr/uploads" \
    nginx:stable \
    || panic "Cannot run linuxfrbackend"

### Wait

podman wait linuxfrorgsetup \
    && echo "linuxfr is up"
