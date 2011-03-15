LinuxFr.org
===========

LinuxFr.org is a french web site speaking of Linux and Free Software.

This git repository is the rails application that run on LinuxFr.org.


Install
-------

The following instructions will help you to install the Rails part of
LinuxFr.org on a Debian box.

1) First install the Debian packages:

    (become root, you should probably remove any preexisting ruby1.8 installation)
    # aptitude install ruby1.9.1-full
    # aptitude install mysql-server mysql-client libmysql++-dev
    # aptitude install build-essential libxslt1-dev libxml2-dev
    # aptitude install imagemagick

2) Install some gems:

    # gem install bundler rake
    (could be gem1.9.1 instead of gem, installation should be in /var/lib/gems/1.9.1 by default)

3) Configure the database:

    # mysql -p -u root
    <enter your root password for mysql>
    > CREATE DATABASE linuxfr_rails;
    > GRANT ALL PRIVILEGES ON linuxfr_rails.* TO "linuxfr_rails"@"localhost";
    > QUIT;
    (return to user)

4) Install and start redis:

    $ wget "http://redis.googlecode.com/files/redis-2.2.1.tar.gz"
    $ tar xzf redis-2.2.1.tar.gz
    $ cd redis-2.2.1
    $ make
    (optional, takes about ten minutes, $ make test )
    $ src/redis-server redis.conf

5) Clone the repository, configure and install gems:

    $ git clone git://github.com/nono/linuxfr.org.git
    $ cd linuxfr.org
    $ cp config/database.yml{.sample,}
    $ cp config/secret.yml{.sample,}
    (become root)
    # bundle install
    (probably /var/lib/gems/1.9.1/bin/bundle if not in your PATH)
    (return to user)
    $ rake db:setup
    (probably /var/lib/gems/1.9.1/bin/rake if not in your PATH)

6) Let's run it:

    $ bundle exec rails server thin
    (probably /var/lib/gems/1.9.1/bin/bundle if not in your PATH)
    $ firefox http://127.0.0.1:3000/
    (did you mean iceweasel?)


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

The [default avatar](http://linuxfr.org/images/default-avatar.png) is a modified
[Tux](http://en.wikipedia.org/wiki/Tux).

[Iconic icons](http://somerandomdude.com/projects/iconic/) are licenced
[CC by-sa 3.0](http://creativecommons.org/licenses/by-sa/3.0/us/).

Copyright (c) 2011 Bruno Michel <NoNo@linuxfr.org>
