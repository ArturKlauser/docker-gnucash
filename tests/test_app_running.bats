#!/usr/bin/env bats

load 'setup'
load 'teardown'

@test "application is running" {
    # Start the container.
    start_container

    # Make sure the application is running.
    run docker exec "${CONTAINER_NAME}" pgrep gnucash
    [ "$status" -eq 0 ]
}
