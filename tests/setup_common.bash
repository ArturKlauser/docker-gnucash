#!/bin/bash

CONTAINER_NAME="gnucash-test-container"

# Starts the container.
#
# DOCKER_ARGS: Extra arguments to pass to the 'docker run' command.
#
start_container() {
    local DOCKER_ARGS="$1"

    # Make sure the container is not already running.
    if [[ "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]]; then
        docker rm -f "${CONTAINER_NAME}" >/dev/null
    fi

    # Start the container.
    echo "Starting container ${CONTAINER_NAME}..."
    docker run -d --name="${CONTAINER_NAME}" ${DOCKER_ARGS} "${DOCKER_IMAGE}" >/dev/null

    # Wait until the container is ready.
    echo "Waiting for container to be ready..."
    local i
    for i in $(seq 1 60); do
        if docker exec "${CONTAINER_NAME}" sv status app | grep -q "run: app"; then
            break
        fi
        sleep 1
    done

    if [[ $i -eq 60 ]]; then
        echo "Container failed to start."
        return 1
    fi
}
