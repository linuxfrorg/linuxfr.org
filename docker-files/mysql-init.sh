#!/bin/bash

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql mysql

mysqladmin create linuxfr_rails
mysql -e "GRANT ALL PRIVILEGES ON linuxfr_rails.* TO linuxfr_rails@localhost;" linuxfr_rails

cd /srv/linuxfr
RAILS_ENV=development bundle exec rake db:setup

redis-cli save
