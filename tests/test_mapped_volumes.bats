#!/bin/env bats

load utils

@test "Checking /config directory existence and ownership" {
  # Permissions of imported volumes are adjusted during startup, so we have to
  # wait for this to happen before checking.
  wait_for_container_daemon
  exec_in_container runuser -u app -- test -e /config
  assert_success # /config exists
  exec_in_container runuser -u app -- test -d /config
  assert_success # /config is a directory
  exec_in_container runuser -u app -- test -O /config
  assert_success # app user owns /config
  exec_in_container runuser -u app -- test -G /config
  assert_success # app group owns /config
}

@test "Checking that /data directory exists and is owned by app user/group..." {
  wait_for_container_daemon
  exec_in_container runuser -u app -- test -e /data
  assert_success # /data exists
  exec_in_container runuser -u app -- test -d /data
  assert_success # /data is a directory
  exec_in_container runuser -u app -- test -O /data
  assert_success # app user owns /data
  exec_in_container runuser -u app -- test -G /data
  assert_success # app group owns /data
}
