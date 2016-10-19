#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR/..


echo -e "Updating nginx vhost map with running containers"
bin/gen-staging-vhost.php

echo -e "Generating index page for available builds"
bin/gen-index-page.php > ${DIR}/../index.html

echo -e "Restarting nginx container"
docker-compose restart