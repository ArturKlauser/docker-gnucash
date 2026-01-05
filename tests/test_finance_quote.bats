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

@test "Checking that gnucash-cli --quotes info works..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" gnucash-cli --quotes info
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Finance::Quote version "[0-9]+\.[0-9]+ ]]
}
