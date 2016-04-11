#!/bin/bash
set -e

# cleanup prev failed builds
docker images | grep ${BUILD_NUMBER} | awk '{ value=$1":"$2; print value }' | xargs docker rmi -f || true

# composer install
export COMPOSER_HOME=/var/lib/jenkins/composer-cache
curl -sS https://getcomposer.org/installer | php
php composer.phar install --ignore-platform-reqs --no-progress --optimize-autoloader --no-interaction --prefer-dist

# spin up node by itself
/bin/docker run --volume ${WORKSPACE}:/var/www --workdir /var/www --rm -e USERID=`id -u jenkins` node:5.6 /var/www/run-node.sh

# bake in the build number to the preview yml file
sed -i 's/%BUILD_TAG%/${BUILD_NUMBER}/g' docker-compose.preview.yml

# pull the latest base image
docker my-registry.com/php-webserver:latest || true
docker pull my-registry.com/php-webserver:latest || true

# build the image for this jenkins build
docker build --force-rm=true --pull --tag="my-registry.com/myapp:${BUILD_NUMBER}" .
