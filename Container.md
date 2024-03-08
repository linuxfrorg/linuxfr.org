LinuxFr with Containers
-----------------------

To simplify set up of a developement environment, LinuxFr.org can be
run with a container engine like Docker or Podman with the [`compose.yml`](./compose.yaml)
file which describe how to build all needed services.

If you use the Docker engine, you can use the `docker compose up` command to start the system (you
need to install the [Docker compose plugin](https://docs.docker.com/compose/)).

> Note: with the Docker engine, you need to enable the Docker BuildKit builder.
> Either you have a Docker version which uses it by default, or you set the
> environment variable `export DOCKER_BUILDKIT=1`.

If you use Podman, you can either use the same Docker compose plugin or the
[podman-compose](https://github.com/containers/podman-compose/)
utility. The podman cli itself provide a wrapper of one of these two tools through the
[`podman compose` command](https://docs.podman.io/en/latest/markdown/podman-compose.1.html).

At this point, the documentation will give you `docker compose` commands, but you should be able
to use `podman compose` without any issue.

To init the SQL database schema, you need to wait upto the `database`
container to be ready to listen MySQL connections.

For example, you should see in the logs:

> database_1       | 2020-09-21 16:03:12 139820938893312 [Note] mysqld: ready for connections.
>
> database_1       | Version: '10.1.46-MariaDB-1\~bionic'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  mariadb.org binary distribution

Then, open a second terminal and run:

```
docker compose run linuxfr.org bin/rails db:setup
```

Finally, the environment is ready and you can open [http://dlfp.lo](http://dlfp.lo)
in your favorite browser.

Notes:

1. to be able to access this URL, you'll need to add the following line
  into the `/etc/hosts` file of your machine:
  
  ```
  127.0.0.1 dlfp.lo image.dlfp.lo
  ```

2. for [rootless containers](https://rootlesscontaine.rs/), you'll need
  to allow standard users to listen on ports less than 1024
  (this is needed because linuxfr use port 80 and 443):

  ```sh
  sudo sysctl net.ipv4.ip_unprivileged_port_start=80
  ```


Personalize configuration
=========================

By default, you don't need to update the configuration.

If you want, you can change the domain names used by the LinuxFr.org
web application. To do this, you can setup `DOMAIN` and `IMAGE_DOMAIN`
variables in the `deployment/default.env` file.

You can also configure your own Redis service and your own MySQL
service.

If you want to change the application port and/or other configurations, you can
[override](https://docs.docker.com/compose/extends/)
the docker compose configuration (in particular the `nginx` service for
the port).

Notice, that if LinuxFr.org doesn't run on port 80, the image cache
service won't work well and so you won't be able to see images in the news.

Test modifications
==================

The compose file currently shares `./app`, `./db` and
`./public` directories with the container.

So you can update files with your prefered IDE on your machine. Rails
will directly detect changes and apply them on next page reload.

Furthermore, if you need to access the Rails console, you need a second
terminal and run:

```
docker compose run linuxfr.org bin/rails console
```

Note: currently, we didn't configure rails to show directly the
`webconsole` in your browser. That's just because of time needed to
find the good configuration, any help will be appreciated !

Run application tests
=====================

To help maintainers, we are in the process of adding tests to check the
application has still the expected behaviour.

To get help about writing tests, see the 
[Ruby on Rails documentation](https://guides.rubyonrails.org/testing.html#the-rails-test-runner)
.

To run tests with containers, you need to use this command:

```
docker compose run linuxfr.org bin/rails test -v
```

Inspect database schema
=======================

In case you need to inspect the database, you need a second terminal
and run:

```
docker compose run database mysql -hdatabase -ulinuxfr_rails -p linuxfr_rails
```

By default, the requested password is the same as the username.

Apply database migrations
=========================

In case you need to apply new database migrations, you need a second
terminal and run:

```
docker compose run linuxfr.org bin/rails db:migrate
```

If you had issue and want to reset all data in your database system,
use:

```
docker compose run linuxfr.org bin/rails db:reset
```

Services provided by the compose file
=======================================

Currently, these services are directly enabled by compose:

1. The [LinuxFr.org](https://github.com/linuxfrorg/linuxfr.org)
ruby on rails application itself
2. The [board service](https://github.com/linuxfrorg/board-sse-linuxfr.org)
which is responsible of tribunes and dynamic collaborative editions
of news
3. The [image service](https://github.com/linuxfrorg/img-LinuxFr.org)
which is caching external images to avoid to
run DOS on external services hosting the images used in news, diaries...

For now, these services aren't available:

1. The [epub service](https://github.com/linuxfrorg/epub-LinuxFr.org),
because it requires to run 
LinuxFr.org with a TLS certificate. When the service will accept to
fetch articles with simple `http://`, we'll be able to provide it
directly with docker compose.
2. The [svgtex service](https://github.com/linuxfrorg/svgtex), because LinuxFr
has hard-coded the `localhost`
hostname in it's [HTML Pipeline tool](https://github.com/linuxfrorg/html-pipeline-linuxfr/blob/linuxfr/lib/html/pipeline/linuxfr.rb#L8)

Fortunately, you can already hack LinuxFr.org deeply without these services.

