FROM debian:stable
MAINTAINER mose <mose@mose.fr>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-mark hold initscripts udev plymouth mountall
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

RUN apt-get -y update

# les paquets comme sur https://github.com/linuxfrorg/linuxfr.org
RUN apt-get -y install mysql-server mysql-client libmysql++-dev \
  build-essential openssl libreadline6 libreadline6-dev \
  curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev \
  libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev bison \
  libxslt-dev autoconf libc6-dev ncurses-dev automake libtool \
  imagemagick hunspell hunspell-fr subversion \
  openjdk-6-jdk tcl8.5 libcurl4-openssl-dev

# les services containeurises
RUN apt-get -y install supervisor openssh-server cron rsyslog vim

# compilons ruby
WORKDIR /tmp
RUN curl -O http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.1.tar.bz2
RUN tar xjf ruby-2.1.1.tar.bz2
WORKDIR /tmp/ruby-2.1.1
RUN ./configure --disable-install-doc
RUN make && make install

# compilons redis
WORKDIR /tmp
RUN curl -O http://redis.googlecode.com/files/redis-2.4.17.tar.gz
RUN tar xzf redis-2.4.17.tar.gz
WORKDIR /tmp/redis-2.4.17
RUN make && make install


RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

ADD docker-files/etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD docker-files/etc/rsyslog.conf /etc/rsyslog.d/50-default.conf
ADD docker-files/etc/crontab /etc/crontab

ADD docker-files/supervisor/rsyslogd.conf /etc/supervisor/conf.d/rsyslogd.conf
ADD docker-files/supervisor/crond.conf /etc/supervisor/conf.d/crond.conf
ADD docker-files/supervisor/sshd.conf /etc/supervisor/conf.d/sshd.conf
ADD docker-files/supervisor/redis.conf /etc/supervisor/conf.d/redis.conf
ADD docker-files/supervisor/mysqld.conf /etc/supervisor/conf.d/mysqld.conf
ADD docker-files/supervisor/rails.conf /etc/supervisor/conf.d/rails.conf

WORKDIR /root
RUN echo "gem: --no-ri --no-rdoc" > .gemrc
RUN gem install bundler
RUN mkdir -p prebundle
WORKDIR /root/prebundle
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

VOLUME ["/srv/linuxfr"]

WORKDIR /root
ADD docker-files/mysql-init.sh /root/mysql-init.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN echo "root:docker" | chpasswd

EXPOSE 22 3000 3306

CMD /usr/bin/supervisord -n

