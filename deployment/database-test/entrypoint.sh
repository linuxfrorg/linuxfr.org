#!/usr/bin/env sh

# Translate environment variable for the database-test service
# Developement environment
export MYSQL_DATABASE=${MYSQL_TEST_DATABASE}
export MYSQL_USER=${MYSQL_TEST_USER}
export MYSQL_PASSWORD=${MYSQL_TEST_PASSWORD}

# Start mysql service as defined in the Dockerfile
exec docker-entrypoint.sh "$@"
