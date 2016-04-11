#!/bin/bash
set -e

# Update Docker compose yaml with build key and number, of image built in build.sh
sed -i 's/%BUILD_TAG%/${BUILD_NUMBER}/g' docker-compose.ci.yml

echo "Unit Tests ..."
/usr/local/bin/docker-compose -f docker-compose.ci.yml run --rm --entrypoint="bash -c " application "bin/phpunit"
