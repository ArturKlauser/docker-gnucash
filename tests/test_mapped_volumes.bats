#!/bin/env bats

load 'setup_suite.bash'

@test "Checking that /config directory exists and is owned by app user/group..." {
  # Permissions of imported volumes are adjusted during startup, so we have to
  # wait for this to happen before checking.
  wait_for_container_daemon
  run exec_in_container runuser -u app -- test -e /config
  echo "exit status: $status (runuser -u app -- test -e /config)"
  [ "$status" -eq  0 ]  # /config exists
  run exec_in_container runuser -u app -- test -d /config
  echo "exit status: $status (runuser -u app -- test -d /config)"
  [ "$status" -eq  0 ]  # /config is a directory
  run exec_in_container runuser -u app -- test -O /config
  echo "exit status: $status (runuser -u app -- test -O /config)"
  [ "$status" -eq  0 ]  # app user owns /config
  run exec_in_container runuser -u app -- test -G /config
  echo "exit status: $status (runuser -u app -- test -G /config)"
  [ "$status" -eq  0 ]  # app group owns /config
}

@test "Checking that /data directory exists and is owned by app user/group..." {
  wait_for_container_daemon
  run exec_in_container runuser -u app -- test -e /data
  echo "exit status: $status (runuser -u app -- test -e /data)"
  [ "$status" -eq  0 ]  # /data exists
  run exec_in_container runuser -u app -- test -d /data
  echo "exit status: $status (runuser -u app -- test -d /data)"
  [ "$status" -eq  0 ]  # /data is a directory
  run exec_in_container runuser -u app -- test -O /data
  echo "exit status: $status (runuser -u app -- test -O /data)"
  [ "$status" -eq  0 ]  # app user owns /data
  run exec_in_container runuser -u app -- test -G /data
  echo "exit status: $status (runuser -u app -- test -G /data)"
  [ "$status" -eq  0 ]  # app group owns /data
}
