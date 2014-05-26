#!/bin/bash

DOCKIP=""

launch() {
  local gitdir=$( cd -P $( dirname $( dirname ${BASH_SOURCE[0]} )) && pwd )
  cd $gitdir
  [ -f config/database.yml ] || cp config/database.yml{.sample,}
  [ -f config/secrets.yml ] || cp config/secrets.yml{.sample,}

  docker run -d -v ${gitdir}:/srv/linuxfr --name linuxfr mose/linuxfr-dev
  DOCKIP=$( docker inspect -f "{{.NetworkSettings.IPAddress}}" linuxfr)
  echo "A container was launched on $DOCKIP."
  echo "ssh root@$DOCKIP"
  echo "x-www-browser http://$DOCKIP:3000"

  if ! grep $DOCKIP /etc/hosts &> /dev/null; then
    sudo sh -c "echo $DOCKIP linuxfr.dev >> /etc/hosts"
  fi

  echo "(type 'docker' when asked for a password)"
  echo "Copying ssh key: "
  ssh root@$DOCKIP "echo \"`cat $HOME/.ssh/*.pub`\" >> /root/.ssh/authorized_keys"
  echo
  echo "Creating user $USER"
  ssh root@$DOCKIP "useradd -u $EUID -m -p docker $USER"
  ssh root@$DOCKIP "mkdir /home/$USER/.ssh && cp /root/.ssh/authorized_keys /home/$USER/.ssh/ && chown $USER /home/$USER/.ssh/"
  ssh root@$DOCKIP " sed -i 's/ -- root/ -- $USER/' /root/rails.sh"
  echo "Launching bundle install --path vendor "
  ssh $DOCKIP "cd /srv/linuxfr && bundle install --path vendor"
  echo
  echo -n "Do you want to refresh the database ? [y/N] "
  read resp
  echo
  if [[ $resp == "y" ]]; then
    ssh root@$DOCKIP /root/mysql-init.sh
  fi
}

launch
