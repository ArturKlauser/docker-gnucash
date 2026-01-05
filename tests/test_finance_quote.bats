#!/bin/env bats

setup() {
    load setup_common
    load setup_container_daemon
}

teardown() {
    load teardown_container_daemon
    load teardown_common
}

@test "Checking that Finance::Quote is installed..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" perl -mFinance::Quote -e 1
    [ "$status" -eq 0 ]
}
