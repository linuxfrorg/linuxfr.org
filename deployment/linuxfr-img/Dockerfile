FROM debian:bullseye-slim as build

LABEL org.opencontainers.image.title="LinuxFr.org image caching service"
LABEL org.opencontainers.image.description="Store external images into a cache to not flood external website"
LABEL org.opencontainers.image.source="https://github.com/linuxfrorg/img-LinuxFr.org"
LABEL org.opencontainers.image.url="https://github.com/linuxfrorg/linuxfr.org/blob/master/Container.md"
LABEL org.opencontainers.image.licenses="AGPL-3.0-only"
LABEL org.opencontainers.image.version="rails7-bullseye"
LABEL org.opencontainers.image.authors="Adrien Dorsaz <adrien@adorsaz.ch>"

ARG UID=1200

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    golang git ca-certificates \
  && apt-get clean

USER ${UID}
ENV GOPATH=/linuxfr-img
ENV HOME=/linuxfr-img
WORKDIR /linuxfr-img

# Build linuxfr-img
RUN go get -u github.com/linuxfrorg/img-LinuxFr.org

FROM debian:bullseye-slim as deploy

USER ${UID}
WORKDIR /linuxfr-img

COPY --from=build --chown=${UID}:0 --chmod=770 /linuxfr-img/bin/img-LinuxFr.org .

EXPOSE 8000

CMD ["sh", "-c", "exec ./img-LinuxFr.org -a 0.0.0.0:8000 -r \"${REDIS_URL##redis://}\""]
