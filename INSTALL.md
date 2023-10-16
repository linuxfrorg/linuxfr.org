# Introduction

This document will give you steps to install LinuxFr.org website on your
Debian Stretch development machine.

Note that all commands which require root access are prefixed by `sudo`.

# Install Debian packages

Packages to install from main Stretch source:

```
~ $ sudo apt install mysql-server mysql-client libmysql++-dev git \
build-essential openssl libreadline-dev curl libcurl4-openssl-dev zlib1g \
zlib1g-dev libssl-dev libxml2-dev libxslt-dev autoconf libgmp-dev libyaml-dev \
ncurses-dev bison automake libtool imagemagick libc6-dev hunspell \
hunspell-fr-comprehensive redis-server ruby ruby-dev ruby-rack
```

Note:
  * you can use libcurl4-gnutls-dev instead of libcurl4-openssl-dev.
  * the `mysql` packages will install MariaDB on Debian Stretch

# Get LinuxFr.org code and external resources

Use git to get LinuxFr.org sources:

```
~ $ git clone git://github.com/linuxfrorg/linuxfr.org.git
```

To be able to reach ruby external resources, you need the `bundler` packager.
The minimal required version is written at the end of the `Gemfile.lock` file.
Actually, Debian has the `1.13.6` version and the lock file requires already
the `1.16.4` version.

So we first install the `bundler` packager directly from `rubygems.org`:

```
~ $ gem install --user-install bundler
```

Don't forget to update your PATH environment according to the warning message
shown during installation.

Now, we can reach external Ruby resources:

```
~ $ cd linuxfr.org
~/linuxfr.org $ bundle config set path 'vendor/bundle'
~/linuxfr.org $ bundle install
~/linuxfr.org $ bundle check
```

The `check` command above should say you there's no problem.

## Install the LinuxFr.org board

The `board-linuxfr` gem server is used to allow users chat on the `/boards` and
the collaborative `redaction` space to work asynchronously.

To install it, the simplest is to run `gem install --user-install board-linuxfr`

# Configure LinuxFr.org

To configure LinuxFr.org, you need to copy both sample configuration files:

```
~/linuxfr.org $ cp config/database.yml{.sample,}
~/linuxfr.org $ cp config/secrets.yml{.sample,}
```

For the database, you'll need to configure both `development` and `test`
section.
Set there the MySQL password you will use for connections in clear text and
eventually the database names to use (they have to be two different databases).
In this document we'll assume you took the default values for database names:
`linuxfr_rails` and `linuxfr_test`.

Note that, on production, you'll need to customize secrets inside
the `secrets.yml` file.

# Configure SQL data base

Prepare time zones information inside the `mysql` database:

```
~ $ mysql_tzinfo_to_sql /usr/share/zoneinfo | sudo mysql mysql
```

Create LinuxFr.org databases and MySQL users:

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

# Run LinuxFr.org

Now, you can run LinuxFr.org server with:

```
~/linuxfr.org $ bin/rails server
```

If everything were good, you can reach the server with a browser inside the
virtual machine using the `http://localhost:3000` URL.

Additionally, you run the boards within another terminal:

```
~/linuxfr.org $ board-linuxfr -s -a localhost -p 9000
```

# Configure redirection

This extra step isn't really needed to be able to use LinuxFr.org.

In the `config/environments/development.rb` file, there are two domains set
inside variables `MY_DOMAIN` and `IMG_DOMAIN`.
By default both domains are `dlfp.lo`.

You'll find this domain inside some documents like emails to confirm user
subscription. To simplify your usage of LinuxFr.org, you should consider
install a website locally using this domain name.

Set the domain `dlfp.lo` to target `localhost`:

```
~ $ sudo bash -c 'echo "127.0.0.1 dlfp.lo" >> /etc/hosts'
```

For Nginx, create a new server configuration with content like:

```
server {
    server_name dlfp.lo;
    access_log /var/log/nginx/dlfp.access.log;

    listen 0.0.0.0:80;

    location ~ ^/medias/ {
      root /home/linuxfr/linuxfr.org/uploads;
    }

    # Avatars files uploaded on linuxfr server are stored in partitions
    # with folder name containing 3 digits
    location ~ ^/avatars/\d\d\d/ { 
      root /home/linuxfr/linuxfr.org/uploads;
    }

    # Avatars URLs has to be served by the image service
    location ~ ^/avatars/ {
        # To install the LinuxFr img service, see: https://github.com/linuxfrorg/img-LinuxFr.org
        proxy_pass http://localhost:8000;
    }

    location /img/ {
        # To install the LinuxFr img service, see: https://github.com/linuxfrorg/img-LinuxFr.org
        proxy_pass http://localhost:8000;
    }

    # To install the LinuxFr board, see: https://github.com/linuxfrorg/board-sse-linuxfr.org
    location /b/ {
        proxy_buffering off;
        proxy_pass http://localhost:9000;
    }

    location / {
        proxy_set_header X_FORWARDED_PROTO $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://localhost:3000;
    }
}
```

and restart the web server:

```
~ $ sudo systemctl restart nginx
```

Now, on the virtual machine, you can access LinuxFr.org with the
`http://dlfp.lo` URL.

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

## Sections for news

To be able to create your first news, you will need to add sections with link
`http://dlfp.lo/admin/section`.

Be sure to set title `LinuxFr.org` to one of your sections, otherwise you won't
be able to create news in the redaction space.
