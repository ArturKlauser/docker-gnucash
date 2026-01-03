#!/usr/bin/env bats

load 'setup'

setup() {
    # Start the container.
    start_container
    sleep 30
}

teardown() {
    # Remove the container.
    docker rm -f "${CONTAINER_NAME}" >/dev/null
}

@test "application is running" {
    # Make sure the application is running.
    run docker exec "${CONTAINER_NAME}" pgrep gnucash
    [ "$status" -eq 0 ]
}
