FROM docker.io/debian:bullseye-slim

LABEL org.opencontainers.image.title="LinuxFr.org website"
LABEL org.opencontainers.image.description="Run LinuxFr.org Ruby on Rails website"
LABEL org.opencontainers.image.source="https://github.com/linuxfrorg/linuxfr.org"
LABEL org.opencontainers.image.url="https://github.com/linuxfrorg/linuxfr.org/blob/master/Docker.md"
LABEL org.opencontainers.image.licenses="AGPL-3.0-only"
LABEL org.opencontainers.image.version="2.0"
LABEL org.opencontainers.image.authors="Adrien Dorsaz <adrien@adorsaz.ch>"

ARG UID=1200

# Install system dependencies
RUN \
  set -eux; \
  IFS=$'\n\t'; \
  apt-get update; \
  apt-get install -y --no-install-recommends --allow-downgrades \
    mariadb-client libmariadb++-dev git \
    build-essential openssl libreadline-dev curl libcurl4-openssl-dev zlib1g \
    zlib1g-dev libssl-dev libxml2-dev libxslt-dev autoconf libgmp-dev libyaml-dev \
    ncurses-dev bison automake libtool imagemagick libc6-dev hunspell \
    hunspell-fr-comprehensive ruby ruby-dev ruby-rack \
    nodejs npm; \
  gem install bundler -v 1.17.3; \
  apt-get clean

USER ${UID}
ENV HOME=/linuxfr.org
WORKDIR /linuxfr.org

# Install node external dependencies
COPY --chown=${UID}:0 --chmod=770 package*.json ./
RUN npm ci

# Install external dependencies
COPY --chown=${UID}:0 --chmod=770 Gemfile* ./

USER 0
RUN \
  set -eux; \
  IFS=$'\n\t'; \
  bundle config set path 'vendor/bundle'; \
  bundle config set deployment 'true'; \
  bundle install; \
  chown ${UID}:0 -R .;

USER ${UID}

# Configure the application
COPY --chown=${UID}:0 --chmod=770 deployment/linuxfr.org/database.yml config/database.yml
COPY --chown=${UID}:0 --chmod=770 config/secrets.yml.sample config/secrets.yml

# Bundle source code
COPY --chown=${UID}:0 --chmod=770 . /linuxfr.org

EXPOSE 3000

CMD ["bin/rails", "server", "--binding", "0.0.0.0"]

