#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"

if [[ -z "${IMAGE_TAG}" ]]; then
    echo "The IMAGE_TAG environment variable is not set. Building a local image for testing."
    IMAGE_TAG="tests-gnucash:test"
    docker build \
        --build-arg BASEIMAGE_VERSION=ubuntu-24.04-v4 \
        --build-arg GNUCASH_VERSION=5.13 \
        -t "${IMAGE_TAG}" "${PROJECT_DIR}"
fi

export IMAGE_TAG
export CONTAINER_NAME="gnucash-test-container"

# Run tests.
echo "Running tests on image ${IMAGE_TAG}..."
bats "${SCRIPT_DIR}/tests"
