LinuxFr.org
===========

LinuxFr.org is a french web site speaking of Linux and Free Software.

This git repository is the rails application that run on LinuxFr.org.


Install
-------

The following instructions will help you to install the Rails part of
LinuxFr.org on a Debian box.

1) First install some Debian packages:

```
# aptitude install mysql-server mysql-client libmysql++-dev git-core
# aptitude install build-essential openssl libreadline-dev
# aptitude install curl libcurl4-openssl-dev zlib1g zlib1g-dev libssl-dev
# aptitude install libxml2-dev libxslt-dev autoconf libgmp-dev libyaml-dev
# aptitude install ncurses-dev bison automake libtool imagemagick libc6-dev
# aptitude install hunspell hunspell-fr-comprehensive redis-server ruby
```

Note: you can use libcurl4-gnutls-dev instead of libcurl4-openssl-dev.

2) Configure the database:

```
# mysql -p -u root
<enter your root password for mysql>
> CREATE DATABASE linuxfr_rails CHARACTER SET utf8;
> GRANT ALL PRIVILEGES ON linuxfr_rails.* TO "linuxfr_rails"@"localhost";
> QUIT;
(return to user)

Statistics need time zone at SQL level. You'll need to population time_zone* tables.
# mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -p -u root mysql
```

3) Clone the repository, configure and install gems:

```
$ git clone git://github.com/linuxfrorg/linuxfr.org.git
$ cd linuxfr.org
$ bin/setup
```

If you are updating, run instead:

```
$ bin/update
```

4) Let's run it:

```
$ bin/rails server
$ x-www-browser http://127.0.0.1:3000/
```

5) Create an admin account:

* Create an account
* Get confirmation link in the console and confirm the account
* Get password in the console
* Give admin role to this account with
  `mysql -u linuxfr_rails linuxfr_rails`
  `mysql> UPDATE accounts SET role='admin' WHERE login='xxxxxx';`
* Reload the page on the site, you should be admin.


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

1. Be sure that redis is running

2. And now, just run rspec (and repeat this step until done):

```
$ bin/rspec spec
```

Copyheart
---------

The code is licensed as GNU AGPLv3. See the LICENSE file for the full license.

The [default avatar](https://linuxfr.org/images/default-avatar.png) is a modified
[Tux](https://en.wikipedia.org/wiki/Tux).

[Iconic icons](http://somerandomdude.com/projects/iconic/) are licenced
[CC by-sa 3.0](https://creativecommons.org/licenses/by-sa/3.0/us/).

♡2011 by Bruno Michel. Copying is an act of love. Please copy and share.
