#!/bin/bash
set -e

docker push my-registry.com/myapp:${BUILD_NUMBER}
