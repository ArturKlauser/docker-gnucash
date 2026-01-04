#!/usr/bin/env bats

load 'setup_common'
load 'teardown_common'

setup() {
    # Start the container.
    start_container
}

@test "application is running" {
    # Make sure the application is running.
    run docker exec "${CONTAINER_NAME}" pgrep gnucash
    [ "$status" -eq 0 ]
}
