#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT=$DIR/..

# Boot up our stack in the background
echo "Creating containers ..."
(cd $ROOT; docker-compose -f docker-compose.yml -f docker-compose.test.yml rm -f application)
(cd $ROOT; docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d)

# Run docker-compose logs until we see that node has finally finished ...
#  Turns out, on a "re-run", node finishes first and we're waiting on fpm.
#  Extra check added.
echo "Waiting for containers to be ready for test-suite ... this will take around one minute"
bash -c 'docker-compose -f docker-compose.yml -f docker-compose.test.yml logs node | { sed "/ Starting / q" && kill -PIPE $$ ; }' > /dev/null 2>&1
bash -c 'docker-compose -f docker-compose.yml -f docker-compose.test.yml logs application | { sed "/fpm is running/ q" && kill -PIPE $$ ; }' > /dev/null 2>&1

echo "Running test suites ..."

$DIR/run-command-in-container bin/phpunit

$DIR/run-command-in-container "bin/behat $@"
