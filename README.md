LinuxFr.org
===========

LinuxFr.org is a French-speaking website about Free software / hardware /
culture / stuff.

This git repository is the rails application that runs on LinuxFr.org.


Install
-------

The following instructions will help you to install the Rails part of
LinuxFr.org on a Debian box.

1) First install some Debian packages:

```
# aptitude install mysql-server mysql-client libmysql++-dev git-core
# aptitude install build-essential openssl libreadline-dev nodejs-legacy
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
> CREATE DATABASE linuxfr_rails CHARACTER SET utf8mb4;
> CREATE USER linuxfr_rails IDENTIFIED BY 'asecretpassword';
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


Copyheart
---------

The code is licensed as GNU AGPLv3. See the LICENSE file for the full license.

The [default avatar](https://linuxfr.org/images/default-avatar.png) is a modified
[Tux](https://en.wikipedia.org/wiki/Tux).

[Feather icons](https://feathericons.com/) are licenced
[MIT](https://github.com/feathericons/feather/blob/master/LICENSE).

♡2011 by Bruno Michel. Copying is an act of love. Please copy and share.
