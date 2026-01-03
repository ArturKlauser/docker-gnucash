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
    docker run -d --name="${CONTAINER_NAME}" ${DOCKER_ARGS} "${DOCKER_IMAGE}" >/dev/null

    # Wait until the container is ready.
    IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CONTAINER_NAME})
    echo "Waiting for container to be ready..."
    wait_for_it ${IP}:5800 -t 60 -q -- echo "Container is ready."
}

#
# Helper function to wait for a TCP port to be available.
#
wait_for_it() {
    local host
    local port
    local timeout=15
    local quiet=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            *:*)
                host=${1%:*}
                port=${1#*:}
                shift 1
                ;;
            -t)
                timeout="$2"
                shift 2
                ;;
            -q)
                quiet=1
                shift 1
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Unknown argument: $1"
                return 1
                ;;
        esac
    done

    if [[ -z "$host" || -z "$port" ]]; then
        echo "Error: host and port must be specified."
        return 1
    fi

    local start_ts=$(date +%s)
    while :
    do
        if (echo > /dev/tcp/$host/$port) >/dev/null 2>&1; then
            break
        fi
        local end_ts=$(date +%s)
        if [[ $((end_ts - start_ts)) -ge $timeout ]]; then
            if [[ $quiet -eq 0 ]]; then
                echo "Timeout occurred after waiting $timeout seconds for $host:$port"
            fi
            return 1
        fi
        sleep 1
    done
}
