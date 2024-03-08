FROM debian:stretch-slim

LABEL maintainer="adrien@adorsaz.ch"
LABEL version="1.0"
LABEL description="Run LinuxFr.org Ruby on Rails website"

WORKDIR /linuxfr.org

# Install system dependencies
# Debian Stretch has been archived so we replace the sources with the archived ones
RUN echo 'deb http://archive.debian.org/debian stretch main' > '/etc/apt/sources.list' \
  && echo 'deb http://archive.debian.org/debian stretch-proposed-updates main' >> '/etc/apt/sources.list' \
  && echo 'deb http://archive.debian.org/debian stretch-backports main' >> '/etc/apt/sources.list.d/linuxfr.list' \
  && apt-get update \
  && apt-get install -y --no-install-recommends --allow-downgrades \
    mysql-client libmysql++-dev git \
    build-essential openssl libreadline-dev curl libcurl4-openssl-dev zlib1g=1:1.2.8.dfsg-5 \
    zlib1g-dev libssl-dev libxml2-dev libxslt-dev autoconf libgmp-dev libyaml-dev \
    ncurses-dev bison automake libtool imagemagick libc6-dev hunspell \
    hunspell-fr-comprehensive ruby ruby-dev ruby-rack \
  && gem install bundler -v 1.17.3 \
  && apt-get clean

RUN mkdir /home/linuxfr.org
ENV HOME /home/linuxfr.org

# Install external dependencies
COPY Gemfile* ./

RUN bundle config set path 'vendor/bundle' \
  && bundle config set deployment 'true' \
  && bundle install

# Configure the application
COPY deployment/linuxfr.org/database.yml config/database.yml
COPY config/secrets.yml.sample config/secrets.yml

# Bundle source code
COPY . /linuxfr.org

EXPOSE 3000

CMD ["bin/rails", "server", "--binding", "0.0.0.0"]

