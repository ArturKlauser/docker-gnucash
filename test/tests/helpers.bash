#!/bin/bash

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
    docker run -d --name="${CONTAINER_NAME}" ${DOCKER_ARGS} "${IMAGE_TAG}" >/dev/null

    # Wait until the container is ready.
    IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CONTAINER_NAME})
    echo "Waiting for container to be ready..."
    "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../wait-for-it.sh" ${IP}:5800 -t 60 -q -- echo "Container is ready."
}

# This function is executed when the test fails.
teardown() {
    # Display log of the container.
    echo "Dumping log of container ${CONTAINER_NAME}..."
    docker logs "${CONTAINER_NAME}"

    # Remove the container.
    echo "Removing container ${CONTAINER_NAME}..."
    docker rm -f "${CONTAINER_NAME}" >/dev/null
}
