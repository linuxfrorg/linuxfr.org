LinuxFr.org
===========

LinuxFr.org is a french web site speaking of Linux and Free Software.

This git repository is the rails application that run on LinuxFr.org.


Install
-------

The following instructions will help you to install the Rails part of
LinuxFr.org on a debian box.

1) First install the debian packages:

    # aptitude install ruby1.8 ruby1.8-dev irb1.8 libopenssl-ruby1.8
    # aptitude install mysql-server mysql-client libmysql++-dev
    # aptitude install build-essential libxslt1-dev libxml2-dev
    # aptitude install aspell libaspell-dev aspell-fr

2) Install rubygems from source (the debian version is too old).
You can follow instructions of
http://railstips.org/blog/archives/2008/11/24/rubygems-yours-mine-and-ours/

3) Configure the database:

    # mysql -p -u root
    <enter your root password for mysql>
    > CREATE DATABASE linuxfr_rails;
    > GRANT ALL PRIVILEGES ON linuxfr_rails.* TO "linuxfr_rails"@"localhost";

4) Clone the repository, configure and install gems:

    $ git clone git://github.com/nono/linuxfr.org.git
    $ cd linuxfr.org
    $ cp config/database.yml{.sample,}
    $ gem install bundler rake
    $ gem install rails rspec-rails devise will_paginate --pre
    $ bundle install
    $ rake db:setup

5) Let's run it:

    $ rails server
    $ firefox http://127.0.0.1:3000/


See also
--------

If you want the full stack for running LinuxFr.org, you should also look at:

* [The admin files](http://github.com/nono/admin-linuxfr.org)
* [The tornado chat](http://github.com/nono/chat-linuxfr.org)
* [The migration script](http://github.com/nono/migration-linuxfr.org)


Copyright
---------

The code is licensed as GNU AGPLv3. See the LICENSE file for the full license.

Copyright (c) 2010 Bruno Michel <NoNo@linuxfr.org>
