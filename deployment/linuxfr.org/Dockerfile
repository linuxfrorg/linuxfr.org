FROM debian:stretch-slim

LABEL maintainer="adrien@adorsaz.ch"
LABEL version="1.0"
LABEL description="Run LinuxFr.org Ruby on Rails website"

WORKDIR /linuxfr.org

RUN echo 'deb http://deb.debian.org/debian stretch-backports main' >> '/etc/apt/sources.list.d/linuxfr.list'

# Install system dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    mysql-client libmysql++-dev git \
    build-essential openssl libreadline-dev curl libcurl4-openssl-dev zlib1g \
    zlib1g-dev libssl-dev libxml2-dev libxslt-dev autoconf libgmp-dev libyaml-dev \
    ncurses-dev bison automake libtool imagemagick libc6-dev hunspell \
    hunspell-fr-comprehensive ruby ruby-dev ruby-rack \
  && apt-get install -t stretch-backports -y --no-install-recommends \
    nodejs npm \
  && gem install bundler \
  && apt-get clean

RUN mkdir /home/linuxfr.org


RUN chown -R 1001:0 /linuxfr.org /home/linuxfr.org \
  && chmod -R g=u /linuxfr.org /home/linuxfr.org

USER 1001:0

ENV HOME /home/linuxfr.org

# Install node external dependencies
COPY package*.json ./
# Note: should use `npm ci`, but it freezes while running, that's strange
RUN npm install --prod

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

# CMD is setting up the database and exec the development server
CMD ["bin/rails", "server", "--binding", "0.0.0.0"]
