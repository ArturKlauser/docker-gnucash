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

@test "Checking that yelp -h works..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" yelp -h
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "Usage:"* ]]
}
