#!/bin/env bats

setup() {
    load setup_common
    load setup_container_daemon
}

teardown() {
    load teardown_container_daemon
    load teardown_common
}

@test "Checking that yelp is installed..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" test -x /usr/bin/yelp
    [ "$status" -eq 0 ]
}
