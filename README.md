LinuxFr.org
===========

LinuxFr.org is a french web site speaking of Linux and Free Software.

This git repository is the rails application that run on LinuxFr.org.


Install
-------

The following instructions will help you to install the Rails part of
LinuxFr.org on a Debian box.

1) First install some Debian packages:

    # aptitude install mysql-server mysql-client libmysql++-dev git-core
    # aptitude install build-essential openssl libreadline6 libreadline6-dev
    # aptitude install curl libcurl4-openssl-dev zlib1g zlib1g-dev libssl-dev
    # aptitude install libxml2-dev libxslt-dev autoconf libgmp-dev libyaml-dev
    # aptitude install ncurses-dev bison automake libtool imagemagick libc6-dev
    # aptitude install hunspell hunspell-fr openjdk-6-jdk redis-server

2) Configure the database:

    # mysql -p -u root
    <enter your root password for mysql>
    > CREATE DATABASE linuxfr_rails;
    > GRANT ALL PRIVILEGES ON linuxfr_rails.* TO "linuxfr_rails"@"localhost";
    > QUIT;
    (return to user)

    Statistics need time zone at SQL level. You'll need to population time_zone* tables.
    # mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -p -u root mysql

3) Install RVM (more details on https://rvm.io/rvm/install ):

    $ curl -L https://get.rvm.io | bash

   And follow the instructions.

4) Install Ruby with RVM:

    $ rvm install 2.1.1
    $ rvm use --default 2.1.1

5) Clone the repository, configure and install gems:

    $ git clone git://github.com/nono/linuxfr.org.git
    $ cd linuxfr.org
    $ cp config/database.yml{.sample,}
    $ cp config/secret.yml{.sample,}
    $ gem install bundler rake
    $ bundle install

6) Finish to configure:

    $ desi install
    $ desi start
    $ rake db:setup
    (if you're updating, you'll need an other step: redis-cli flushdb)
    $ bundle exec rake elasticsearch:import FORCE=y

7) Let's run it:

    $ ./script/rails server thin
    $ x-www-browser http://127.0.0.1:3000/

8) Create an admin account:

* Create an account
* Get confirmation link in the console and confirm the account
* Get password in the console
* Give admin role to this account with
  `mysql linuxfr_rails`
  `mysql> UPDATE accounts SET role='admin' WHERE login='xxxxxx';`
* Reload the page on the site, you should be admin.


See also
--------

If you want the full stack for running LinuxFr.org, you should also look at:

* [The admin files](https://github.com/nono/admin-linuxfr.org)
* [The migration script](https://github.com/nono/migration-linuxfr.org)
* [The board daemon](https://github.com/nono/board-sse-linuxfr.org)
* [The share daemon](https://github.com/nono/share-LinuxFr.org)
* [The epub daemon](https://github.com/nono/epub-LinuxFr.org)
* [The img daemon](https://github.com/nono/img-LinuxFr.org)


How to run the specs
--------------------

1) Be sure that redis and ElasticSearch are running

2) Create the test database:

    $ bundle exec rake db:test:prepare

3) And now, just run rspec (and repeat this step until done):

    $ bundle exec rspec spec


How to generate a CSS
---------------------

CSS are written in sass and compiled with the Rails assets pipeline.
If you just want to compile a CSS without installing Rails and all its
dependency, you can install the `sass` gem and launch:

    ./script/compile_sass app/assets/stylesheets/application.css.scss > app.css


Copyheart
---------

The code is licensed as GNU AGPLv3. See the LICENSE file for the full license.

The [default avatar](http://linuxfr.org/images/default-avatar.png) is a modified
[Tux](http://en.wikipedia.org/wiki/Tux).

[Iconic icons](http://somerandomdude.com/projects/iconic/) are licenced
[CC by-sa 3.0](http://creativecommons.org/licenses/by-sa/3.0/us/).

♡2011 by Bruno Michel. Copying is an act of love. Please copy and share.
