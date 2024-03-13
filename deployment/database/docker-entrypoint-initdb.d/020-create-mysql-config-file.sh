#/usr/bin/env sh

set -euo pipefail

cat > /etc/mysql/conf.d/linuxfr.cnf <<EOCNF
[client]
host = ${MYSQL_HOST}
user = ${MYSQL_USER}
password = ${MYSQL_PASSWORD}
EOCNF
