#!/bin/env bats

load utils

setup_file() {
  setup_all
}

teardown_file() {
  teardown_all
}

@test "Checking that /startapp.sh exists..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" test -f /startapp.sh
  [ "$status" -eq 0 ]
}

@test "Checking that /startapp.sh has execute permissions..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" test -x /startapp.sh
  [ "$status" -eq 0 ]
}
