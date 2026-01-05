#!/bin/env bats

load utils

setup_file() {
  setup_all
}

teardown_file() {
  teardown_all
}

@test "Checking APP_NAME environment variable..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" printenv APP_NAME
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "GnuCash" ]
}

@test "Checking SECURE_CONNECTION environment variable is set..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" printenv SECURE_CONNECTION
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "1" ]
}

@test "Checking XDG_CONFIG_HOME environment variable points to /config..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" printenv XDG_CONFIG_HOME
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_DATA_HOME environment variable points to /config..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" printenv XDG_DATA_HOME
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_CACHE_HOME environment variable points to /config..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" printenv XDG_CACHE_HOME
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "/config/"* ]]
}
