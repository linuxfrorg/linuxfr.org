LinuxFr.org
===========

LinuxFr.org is a french web site speaking of Linux and Free Software.

This git repository is the rails application that run on LinuxFr.org.


Install
-------

The following instructions will help you to install the Rails part of
LinuxFr.org on a debian box.

1) First install the debian packages:

    # aptitude install ruby1.9.1-full
    # aptitude install mysql-server mysql-client libmysql++-dev
    # aptitude install build-essential libxslt1-dev libxml2-dev
    # aptitude install imagemagick

2) Configure the database:

    # mysql -p -u root
    <enter your root password for mysql>
    > CREATE DATABASE linuxfr_rails;
    > GRANT ALL PRIVILEGES ON linuxfr_rails.* TO "linuxfr_rails"@"localhost";

3) Install and start redis:

    $ wget "http://redis.googlecode.com/files/redis-2.2.0-rc4.tar.gz"
    $ tar xvzf redis-2.2.0-rc4.tar.gz
    $ cd redis-2.2.0-rc4
    $ make
    $ ./redis-server redis.conf

4) Clone the repository, configure and install gems:

    $ git clone git://github.com/nono/linuxfr.org.git
    $ cd linuxfr.org
    $ cp config/database.yml{.sample,}
    $ cp config/secret.yml{.sample,}
    $ gem install bundler rake
    $ bundle install
    $ rake db:setup

5) Let's run it:

    $ bundle exec rails server thin
    $ firefox http://127.0.0.1:3000/


See also
--------

If you want the full stack for running LinuxFr.org, you should also look at:

* [The admin files](http://github.com/nono/admin-linuxfr.org)
* [The eventmachine chat](http://github.com/nono/Board-LinuxFr.org)
* [The migration script](http://github.com/nono/migration-linuxfr.org)


How to run the specs
--------------------

1) Be sure that redis is running and create the test database:

    $ rake db:test:prepare

2) Run [spork](https://github.com/timcharper/spork) in background:

    $ spork &

3) And now, just run rspec (and repeat this step until done):

    $ rspec spec


Copyright
---------

The code is licensed as GNU AGPLv3. See the LICENSE file for the full license.

Copyright (c) 2011 Bruno Michel <NoNo@linuxfr.org>
