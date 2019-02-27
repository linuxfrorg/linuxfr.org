# Introduction

This document will give you steps to install linuxfr.org website on your
Debian Stretch development machine.

Note that all commands which require root access are prefixed by `sudo`.

# Use stretch-backports

LinuxFr requires to add `stretch-backports` source package as it needs the `npm`
package.

```
~ $ sudo bash -c "echo 'deb http://deb.debian.org/debian stretch-backports main' >> /etc/apt/sources.list.d/linuxfr.list"
~ $ sudo apt update
```

# Install Debian packages

Packages to install from main Stretch source:

```
~ $ sudo apt install mysql-server mysql-client libmysql++-dev git \
build-essential openssl libreadline-dev curl libcurl4-openssl-dev zlib1g \
zlib1g-dev libssl-dev libxml2-dev libxslt-dev autoconf libgmp-dev libyaml-dev \
ncurses-dev bison automake libtool imagemagick libc6-dev hunspell \
hunspell-fr-comprehensive redis-server ruby ruby-dev
```

Note:
  * you can use libcurl4-gnutls-dev instead of libcurl4-openssl-dev.
  * the `mysql` packages will install MariaDB on Debian Stretch

Packages to install from backports:

```
~ $ sudo apt install -t stretch-backports nodejs npm
```

# Get LinuxFr code and external resources

Use git to get LinuxFr sources:

```
~ $ git clone git://github.com/linuxfrorg/linuxfr.org.git
```

To be able to reach ruby external resources, you need the `bundler` packager.
The minimal required version is written at the end of the `Gemfile.lock` file.
Actually, Debian has the `1.13.6` version and the lock file requires already
the `1.16.4` version.

So we first install the `bundler` packager directly from `rubygems.org`:

```
~ $ sudo gem install bundler
```

Now, we can reach external Ruby resources:

```
~ $ cd linuxfr.org
~/linuxfr.org $ bundle install --path vendor/bundle
~/linuxfr.org $ bundle check
```

The `check` command above should say you there's no problem.

Linuxfr uses also some nodejs resources:

```
~/linuxfr.org $ npm install
```

# Configure LinuxFr

To configure LinuxFr, you need to copy both sample configuration files:

```
~/linuxfr.org $ cp config/database.yml{.sample,}
~/linuxfr.org $ cp config/secrets.yml{.sample,}
```

For database, you'll need to configure both `development` and `test` section.
Set there the MySQL password you will use for connections in clear text and
evenutally the database names to use (they have to be two different databases).
In this document we'll assume you took the default values for database names:
`linuxfr_rails` and `linuxfr_test`.

Note that, on production, you'll need to customize secrets inside
the `secrets.yml` file.

# Configure SQL data base

Prepare time zones informations inside the `mysql` database:

```
~ $ mysql_tzinfo_to_sql /usr/share/zoneinfo | sudo mysql mysql
```

Create LinuxFr databases and MySQL users:

```
~/linuxfr.org $ sudo mysql
> CREATE DATABASE linuxfr_rails CHARACTER SET utf8mb4;
> CREATE USER linuxfr_rails IDENTIFIED BY 'linuxfr_rails password';
> GRANT ALL PRIVILEGES ON linuxfr_rails.* TO linuxfr_rails;
>
> CREATE DATABASE linuxfr_test CHARACTER SET utf8mb4;
> CREATE USER linuxfr_test IDENTIFIED BY 'linuxfr_test password';
> GRANT ALL PRIVILEGES ON linuxfr_test.* TO linuxfr_test;
>
> quit
```

Now every thing is ready and we can ask `rails` to setup our databases with
every structures needed:

```
~/linuxfr.org $ bin/rails db:setup
```

# Run LinuxFr

Now, you can run LinuxFr server with:

```
~/linuxfr.org $ bin/rails server
```

If everything was good, you can reach the server with a browser inside the
virtual machine using the `http://localhost:3000` URL.

# Configure redirection

This extra step isn't really needed to be able to use Linuxfr.

In the `config/environments/development.rb` file, there are two domains set
inside variables `MY_DOMAIN` and `IMG_DOMAIN`.
By default both domains are `dlfp.lo`.

You'll find this domain inside some documents like emails to confirm user
subscription. To simplify your usage of Linuxfr, you should consider install a
website locally using this domain name.

Set the domain `dlfp.lo` to target localhost:

```
~ $ sudo bash -c 'echo "127.0.0.1 dlfp.lo" >> /etc/hosts'
```

For Apache, create a new virtual host file configuration and add:

```
ServerName dlfp.lo
ProxyPass / http://localhost:3000/
ProxyPassReverse / http://localhost:3000/
```

and enable this website and the proxy module:

```
~ $ sudo a2enmod proxy_http proxy
~ $ sudo a2ensite dlfp
~ $ sudo systemctl restart apache2
```

Now, on the virtual machine, you can access Linuxfr with the `http://dlfp.lo`
URL.

# Create administrator

To create new users, you can use directly the website.

Although, to set roles on users, you need to manually edit one user directly
in the database.

For example, to set as admin the user with login `admin_login`:

```
$ sudo mysql linuxfr_rails
> update accounts set role = 'admin' where login = 'admin_login' ;
```

Then, you can update other users role directly from the URL
`http://dlfp.lo/admin/comptes`.

Finally, you'll certainly need to visit `http://dlfp.lo/admin/` to
configure sections, forums...
