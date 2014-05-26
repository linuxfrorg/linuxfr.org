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

Note: you can use libcurl4-gnutls-dev instead of libcurl4-openssl-dev.

2) Configure the database:

    # mysql -p -u root
    <enter your root password for mysql>
    > CREATE DATABASE linuxfr_rails CHARACTER SET utf8;
    > GRANT ALL PRIVILEGES ON linuxfr_rails.* TO "linuxfr_rails"@"localhost";
    > QUIT;
    (return to user)

    Statistics need time zone at SQL level. You'll need to population time_zone* tables.
    # mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -p -u root mysql

3) Install Ruby with RVM (more details on https://rvm.io/rvm/install ):

    $ \curl -sSL https://get.rvm.io | bash -s stable --ruby

   And follow the instructions.

4) Clone the repository, configure and install gems:

    $ git clone git://github.com/linuxfrorg/linuxfr.org.git
    $ cd linuxfr.org
    $ cp config/database.yml{.sample,}
    $ cp config/secrets.yml{.sample,}
    $ bundle install

5) Finish to configure:

    $ desi install
    $ desi start
    $ bin/rake db:setup
    (if you're updating, you'll need an other step: redis-cli flushdb)
    $ bin/rake elasticsearch:import FORCE=y

6) Let's run it:

    $ bin/rails server
    $ x-www-browser http://127.0.0.1:3000/

7) Create an admin account:

* Create an account
* Get confirmation link in the console and confirm the account
* Get password in the console
* Give admin role to this account with
  `mysql linuxfr_rails`
  `mysql> UPDATE accounts SET role='admin' WHERE login='xxxxxx';`
* Reload the page on the site, you should be admin.

Alternative install (docker)
-----------------------------

The whole install process may seem a bit tedious especially if your environment
is not already set for ruby development, and it may discourage contributions for
small things like css or quick bugfix.

In such case and if you have a recent kernel (3.8+) you can give docker a try.
The big plus is that you don't have to install ruby,l, mysql, or whatever, it all
will be 'contained' in the docker image.

Step by step:

- install docker (see http://docs.docker.io/installation)
- pull the premade image
  - `docker pull mose/linuxfr-dev`
- or if you already know docker make your own with the `Dockerfile` present in the repo
  - `docker build -t linuxfr .`
- remove `database.yml` if you already customised it, as it will use the default one
- launch the container either manually
  - `docker run -d -v /path/to/linuxfr-cloned-repo:/srv/linuxfr --name linuxfr mose/linuxfr-dev`
- or use the small bash script
  - `./docker-files/docker.sh`
  - the script will propose you to refresh or not the db
  - it will tell you on what local natted IP the container is launched (let's say 172.17.0.2)
- you can access the launched app
  - `x-www-browser http://172.17.0.2:3000` reach the app in your browser
  - `mysql -h 172.17.0.2 -ulinuxfr.dev linuxfr_rails` to access the db
  - `ssh root@172.17.0.2` and password `docker` to reach it via ssh
- you will have to do the step 7 from the normal install for init the admin account.

Usage:

- your local git clone of linuxfr.org code is mounted in the container,
  so all you change in your local dir are taken in account immediatelyin the container
- `docker ps` should list the container if it's launched
- `docker stop linuxfr` stops the container
- `docker run linuxf` restarts the container if it was stopped
- `docker rm linuxfr` will erase a container so you can relaunch a fresh one from the image
- `docker images` lists the docker images you can launch
- the docker.sh script also puts a linuxfr.dev somain resolution to the container ip for ease of use
- you can launch a rails console with `ssh root@linuxfr.dev "cd /srv/linuxfr && bundle exec rails c"`

Limitations:

- elasticsearch is not yet included in the docker image
- this dockerisation is still experimental and not very well tested but it proved to work at least once
- please report any bugs or suggest improvements by opening an issue.


See also
--------

If you want the full stack for running LinuxFr.org, you should also look at:

* [The admin files](https://github.com/linuxfrorg/admin-linuxfr.org)
* [The migration script](https://github.com/linuxfrorg/migration-linuxfr.org)
* [The board daemon](https://github.com/linuxfrorg/board-sse-linuxfr.org)
* [The share daemon](https://github.com/linuxfrorg/share-LinuxFr.org)
* [The epub daemon](https://github.com/linuxfrorg/epub-LinuxFr.org)
* [The img daemon](https://github.com/linuxfrorg/img-LinuxFr.org)
* [SVGTeX](https://github.com/linuxfrorg/svgtex)


How to run the specs
--------------------

1) Be sure that redis and ElasticSearch are running

2) And now, just run rspec (and repeat this step until done):

    $ bin/rspec spec


How to generate a CSS
---------------------

CSS are written in sass and compiled with the Rails assets pipeline.
If you just want to compile a CSS without installing Rails and all its
dependency, you can install the `sass` gem and launch:

    bin/compile_sass app/assets/stylesheets/application.css.scss > app.css


Copyheart
---------

The code is licensed as GNU AGPLv3. See the LICENSE file for the full license.

The [default avatar](http://linuxfr.org/images/default-avatar.png) is a modified
[Tux](http://en.wikipedia.org/wiki/Tux).

[Iconic icons](http://somerandomdude.com/projects/iconic/) are licenced
[CC by-sa 3.0](http://creativecommons.org/licenses/by-sa/3.0/us/).

♡2011 by Bruno Michel. Copying is an act of love. Please copy and share.
