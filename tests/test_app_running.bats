#!/bin/env bats

setup() {
    load setup_common
    load setup_container_daemon
}

teardown() {
    load teardown_container_daemon
    load teardown_common
}

@test "Checking that the gnucash application is running..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" pgrep gnucash
    [ "$status" -eq 0 ]
}
