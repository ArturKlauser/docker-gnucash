#!/bin/bash

CONTAINER_NAME="gnucash-test-container"

# Starts the container.
#
# DOCKER_ARGS: Extra arguments to pass to the 'docker run' command.
#
start_container() {
    local DOCKER_ARGS="$1"
    local IP

    # Make sure the container is not already running.
    if [[ "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]]; then
        docker rm -f "${CONTAINER_NAME}" >/dev/null
    fi

    # Start the container.
    echo "Starting container ${CONTAINER_NAME}..."
    docker run -d --name="${CONTAINER_NAME}" ${DOCKER_ARGS} "${DOCKER_IMAGE}" >/dev/null

    # Wait until the container is ready.
    echo "Waiting for container to be ready..."
    sleep 30
}
