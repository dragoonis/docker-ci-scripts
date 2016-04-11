#!/bin/bash
set -e

docker rmi -f my-registry.com/myapp:${BUILD_NUMBER} || exit 0
