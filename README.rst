=============
linuxfr.org 3
=============

---------------
moules on rails
---------------


This is a placeholder.

Try out the next bouchot
========================

Easy pizzy, once you installed gem (rubygems in archlinux)! ::

  [as root] gem sources -a http://gems.github.com
  [as root] gem install rails haml rake sqlite3-ruby mojombo-grit
  git clone git://github.com/nono/linuxfr.org.git
  cd linuxfr.org
  cp config/database.yml.sample config/database.yml
  git submodule update --init
  [as root] sudo rake gems:install
  rake db:migrate
  ruby script/server

It (supposedly) serves the website on http://0.0.0.0:3000
