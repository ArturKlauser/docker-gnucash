#!/bin/bash

# This function is executed when the test fails.
teardown() {
    # Display log of the container.
    echo "Dumping log of container ${CONTAINER_NAME}..."
    docker logs "${CONTAINER_NAME}"

    # Remove the container.
    echo "Removing container ${CONTAINER_NAME}..."
    docker rm -f "${CONTAINER_NAME}" >/dev/null
}
