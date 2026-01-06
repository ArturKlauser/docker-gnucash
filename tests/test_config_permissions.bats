#!/bin/env bats

setup() {
    load setup_common
    load setup_container_daemon
}

teardown() {
    load teardown_container_daemon
    load teardown_common
}

@test "Checking that /config has read/write/execute permissions for the app user..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" runuser -u app -- test -r /config -a -w /config -a -x /config
    [ "$status" -eq 0 ]
}
