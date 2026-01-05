#!/bin/env bats

setup() {
    load setup_common
    load setup_container_daemon
}

teardown() {
    load teardown_container_daemon
    load teardown_common
}

@test "Checking APP_NAME environment variable..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" printenv APP_NAME
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "GnuCash" ]
}

@test "Checking SECURE_CONNECTION environment variable..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" printenv SECURE_CONNECTION
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "1" ]
}

@test "Checking XDG_CONFIG_HOME environment variable..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" printenv XDG_CONFIG_HOME
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_DATA_HOME environment variable..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" printenv XDG_DATA_HOME
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_CACHE_HOME environment variable..." {
    run docker exec "${CONTAINER_DAEMON_NAME}" printenv XDG_CACHE_HOME
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "/config/"* ]]
}
