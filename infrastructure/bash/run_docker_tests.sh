#!/usr/bin/env bash

set -e
set -x

# build images
docker-compose -f testing-stack.yaml build

# run tests
docker-compose -f testing-stack.yaml up --abort-on-container-exit --exit-code-from tests tests
