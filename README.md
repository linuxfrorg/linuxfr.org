LinuxFr.org
===========

LinuxFr.org is a french web site speaking of Linux and Free Software.

This git repository is the rails application that run on LinuxFr.org.


Install
-------

The following instructions will help you to install the Rails part of
LinuxFr.org on a debian box.

Note: I use Ruby 1.9.2 with RVM, even if it's not packaged for debian,
but these explanations are for Ruby 1.8. The two versions work, so
you are free to choose your camp.

1) First install the debian packages:

    # aptitude install ruby1.8 ruby1.8-dev irb1.8 libopenssl-ruby1.8
    # aptitude install mysql-server mysql-client libmysql++-dev
    # aptitude install build-essential libxslt1-dev libxml2-dev
    # aptitude install aspell libaspell-dev aspell-fr

2) Install rubygems

The rubygems package for debian lenny is too old. You can install it from
sources, by following the instructions of
http://railstips.org/blog/archives/2008/11/24/rubygems-yours-mine-and-ours/

On later debians, just do:

    # aptitude install rubygems

3) Configure the database:

    # mysql -p -u root
    <enter your root password for mysql>
    > CREATE DATABASE linuxfr_rails;
    > GRANT ALL PRIVILEGES ON linuxfr_rails.* TO "linuxfr_rails"@"localhost";

4) Install and start redis:

    $ wget "http://redis.googlecode.com/files/redis-2.0.4.tar.gz"
    $ tar xvzf redis-2.0.4.tar.gz
    $ cd redis-2.0.4
    $ make
    $ ./redis-server redis.conf

5) Clone the repository, configure and install gems:

    $ git clone git://github.com/nono/linuxfr.org.git
    $ cd linuxfr.org
    $ cp config/database.yml{.sample,}
    $ cp config/secret.yml{.sample,}
    $ gem install bundler rake
    $ bundle install
    $ rake db:setup

6) Let's run it:

    $ bundle exec rails server thin
    $ firefox http://127.0.0.1:3000/


See also
--------

If you want the full stack for running LinuxFr.org, you should also look at:

* [The admin files](http://github.com/nono/admin-linuxfr.org)
* [The eventmachine chat](http://github.com/nono/Board-LinuxFr.org)
* [The migration script](http://github.com/nono/migration-linuxfr.org)


Copyright
---------

The code is licensed as GNU AGPLv3. See the LICENSE file for the full license.

Copyright (c) 2010 Bruno Michel <NoNo@linuxfr.org>
