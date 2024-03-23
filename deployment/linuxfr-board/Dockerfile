FROM docker.io/ruby:2-slim-buster

LABEL org.opencontainers.image.title="Board for LinuxFr.org"
LABEL org.opencontainers.image.description="Users of the LinuxFr.org website can chat on a space called the board (« la tribune » in french). \
This Ruby daemon notifies the users when something is said with Server-Sent Event / EventSource."
LABEL org.opencontainers.image.source="https://github.com/linuxfrorg/board-sse-linuxfr.org"
LABEL org.opencontainers.image.url="https://github.com/linuxfrorg/board-sse-linuxfr.org"
LABEL org.opencontainers.image.licenses="AGPL-3.0-only"
LABEL org.opencontainers.image.version="1.1"
LABEL org.opencontainers.image.authors="Adrien Dorsaz <adrien@adorsaz.ch>"

ARG UID=1200

RUN \
  set -eux; \
  IFS=$'\n\t'; \
  apt-get update; \
  # Install dependencies \
  # and add curl to be used by the healthcheck defined in compose.yaml \
  apt-get install -y --no-install-recommends \
    build-essential git ruby ruby-dev \
    curl; \
  apt-get clean;

USER ${UID}
WORKDIR /linuxfr-board
ENV HOME=/linuxfr-board

# Install board-linuxfr
RUN gem install board-linuxfr -v '~> 0.1.3'

# Clean development dependencies
USER 0
RUN apt-get purge --autoremove -y build-essential ruby-dev

USER ${UID}
EXPOSE 9000

CMD ["board-linuxfr"]
