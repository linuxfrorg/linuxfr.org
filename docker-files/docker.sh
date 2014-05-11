#!/bin/bash

DOCKIP=""

launch() {
  local gitdir=$( cd -P $( dirname $( dirname ${BASH_SOURCE[0]} )) && pwd )
  cd $gitdir
  [ -f config/database.yml ] || cp config/database.yml{.sample,}
  [ -f config/secrets.yml ] || cp config/secrets.yml{.sample,}

  docker run -d -v ${gitdir}:/srv/linuxfr --name linuxfr mose/linuxfr-dev
  DOCKIP=$( docker inspect -f "{{.NetworkSettings.IPAddress}}" linuxfr)
  if ! grep $DOCKIP /etc/hosts &> /dev/null; then
    sudo sh -c "echo $DOCKIP linuxfr.dev >> /etc/hosts"
  fi
  echo "Un containeur a ete lance sur $DOCKIP."
  echo "ssh root@$DOCKIP (pass: docker)"
  echo "open http://$DOCKIP:3000"
  echo
  echo -n "Do you want a fresh database ? [y/N] "
  read resp
  echo
  if [[ $resp == "y" ]]; then
    echo "(Type 'docker')"
    ssh root@$DOCKIP /root/mysql-init.sh
  fi
}

launch
