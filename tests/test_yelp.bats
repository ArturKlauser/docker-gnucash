#!/bin/env bats

load utils

setup_file() {
  setup_all
}

teardown_file() {
  teardown_all
}

@test "Checking that yelp is installed properly..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" which yelp
  echo "exit status: $status"
  [ "$status" -eq 0 ]
  yelp_app="${lines[0]}"
  run docker exec "${CONTAINER_DAEMON_NAME}" test -x "${yelp_app}"
  echo "exit status: $status"
  [ "$status" -eq 0 ]
}

@test "Checking that yelp runs..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" yelp -h
  echo "exit status: $status"
  [ "$status" -eq 0 ]
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "Usage:"* ]]
}
