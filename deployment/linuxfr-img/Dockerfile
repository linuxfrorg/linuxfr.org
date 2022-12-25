FROM debian:bullseye-slim as build

LABEL maintainer="adrien@adorsaz.ch"
LABEL version="2.0"
LABEL description="Run LinuxFr image caching service for LinuxFr.org"

ENV GOPATH=/linuxfr-img
WORKDIR /linuxfr-img

# Build linuxfr-img
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    golang git ca-certificates \
  && apt-get clean \
  && go get -u github.com/linuxfrorg/img-LinuxFr.org

FROM debian:bullseye-slim as deploy

WORKDIR /linuxfr-img

COPY --from=build /linuxfr-img/bin/img-LinuxFr.org .

EXPOSE 8000

CMD ["sh", "-c", "exec ./img-LinuxFr.org -a 0.0.0.0:8000 -r \"${REDIS_URL##redis://}\""]
