FROM debian:bullseye-slim

LABEL maintainer="adrien@adorsaz.ch"
LABEL version="1.0"
LABEL description="Run LinuxFr image caching service for LinuxFr.org Ruby on Rails website"

WORKDIR /linuxfr-img

# Install dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    golang git ca-certificates \
  && apt-get clean

# Install linuxfr-img
ENV GOPATH=/linuxfr-img/go
ENV PATH=${PATH}:/linuxfr-img/go/bin
RUN go get -u github.com/linuxfrorg/img-LinuxFr.org

EXPOSE 8000

CMD ["sh", "-c", "exec img-LinuxFr.org -a 0.0.0.0:8000 -r \"${REDIS_URL##redis://}\""]
