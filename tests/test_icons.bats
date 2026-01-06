#!/bin/env bats

load utils

setup_file() {
  setup_all
}

teardown_file() {
  teardown_all
}

@test "Checking that app web icons exist..." {
  icon_dir='/opt/noVNC/app/images/icons'
  run docker exec "${CONTAINER_DAEMON_NAME}" test -d "${icon_dir}"
  [ "$status" -eq  0 ]  # icons exists
  run docker exec "${CONTAINER_DAEMON_NAME}" test -e "${icon_dir}/favicon.ico"
  [ "$status" -eq  0 ]  # web favicon exists
}
