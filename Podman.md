LinuxFr on Podman
-----------------

To simplify set up of a developement environment, LinuxFr.org can be
run on Podman with two shell scripts:

    ./podman-build.sh # build containers
    ./podman-run.sh # run containers in a pod named linuxfr

You should prefer podman to [Docker compose](./Docker.md) when you
dont have enough privilege on your development machine (the podman script
are rootless/daemonless).

Finally, the environment is ready and you can open [http://localhost:8080](http://localhost:8080)
in your favorite browser.

