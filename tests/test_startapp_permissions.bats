#!/bin/env bats

setup() {
    load setup_common
    load setup_container_daemon
}

teardown() {
    load teardown_container_daemon
    load teardown_common
}

@test "Checking that /startapp.sh exists..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" test -f /startapp.sh
    [ "$status" -eq 0 ]
}

@test "Checking that /startapp.sh has execute permissions..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" test -x /startapp.sh
    [ "$status" -eq 0 ]
}
