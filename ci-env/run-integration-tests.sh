#!/bin/bash
set -e

# Update Docker compose yaml with build key and number, of image built in build.sh
sed -i 's/%BUILD_TAG%/${BUILD_NUMBER}/g' docker-compose.ci.yml

# Boot up our stack in the background
echo "Creating containers ..."
/usr/local/bin/docker-compose -f docker-compose.ci.yml up -d

echo "Waiting for containers to be ready for test-suite ... this will take around one minute"

# wait until we see "fpm is running" then we're ready to begin our test suite
bash -c '/usr/local/bin/docker-compose -f docker-compose.ci.yml logs application | { sed "/fpm is running/ q" && kill -PIPE $$ ; }' > /dev/null 2>&1

# execute integration tests
docker-compose -f docker-compose.ci.yml run --rm --entrypoint="bash -c " application "bin/behat --profile=ci -f pretty -f html -f junit --suite=endtoend"

# clean up old volumes too
docker-compose -f docker-compose.ci.yml down -v
