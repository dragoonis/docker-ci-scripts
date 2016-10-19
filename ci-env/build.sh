#!/bin/bash
set -e

# cleanup prev failed builds
docker images | grep ${BUILD_NUMBER} | awk '{ value=$1":"$2; print value }' | xargs docker rmi -f || true

# spin up node by itself
/bin/docker run --volume ${WORKSPACE}:/var/www --workdir /var/www --rm -e USERID=`id -u jenkins` node:5.6 /var/www/run-node.sh

# bake in the build number to the preview yml file
sed -i 's/%BUILD_TAG%/${BUILD_NUMBER}/g' docker-compose.qa.yml

# pull the latest base image
docker pull my-registry.com/php-webserver-base:latest || true

# build the image for this jenkins build
docker build --force-rm=true --pull --tag="my-registry.com/myapp:${BUILD_NUMBER}" .
