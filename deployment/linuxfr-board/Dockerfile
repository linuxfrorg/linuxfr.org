FROM debian:stretch-slim

LABEL maintainer="adrien@adorsaz.ch"
LABEL version="1.0"
LABEL description="Run LinuxFr board service for LinuxFr.org Ruby on Rails website"

WORKDIR /linuxfr-board

# Install dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential ruby ruby-dev \
  && apt-get clean

# Install board-linuxfr
RUN gem install board-linuxfr -v '~> 0.1.3'

RUN apt purge --autoremove -y build-essential ruby-dev

EXPOSE 9000

CMD ["board-linuxfr"]
