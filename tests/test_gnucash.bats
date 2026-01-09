#!/bin/env bats

load utils

setup_file() {
  setup_all
}

teardown_file() {
  teardown_all
}

@test "Checking that Gnucash is installed properly..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" which gnucash
  echo "exit status: $status (which gnucash)"
  [ "$status" -eq 0 ]
  run docker exec "${CONTAINER_DAEMON_NAME}" test -x "${lines[0]}"
  echo "exit status: $status (test -x \"${lines[0]}\")"
  [ "$status" -eq 0 ]
}

@test "Checking that Gnucash runs..." {
  # Modern Gnucash can't even print verion or help messages to the TTY if it
  # can't pass it's GTK GUI startup. That only works if a display is set and
  # an X-server is actually running there. So we have to wait for the whole
  # container to start up before we can test even the most basic gnucash
  # invocation.
  wait_for_container_daemon
  run docker exec "${CONTAINER_DAEMON_NAME}" \
    sh -c 'gnucash --display=:0 --version'
  echo "exit status: $status (gnucash --display=:0 --version)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" =~ "GnuCash "[0-9]+\.[0-9]+ ]]
}

@test "Checking Gnucash GNC_USERDATA_DIR points to /config..." {
  wait_for_container_daemon
  run docker exec "${CONTAINER_DAEMON_NAME}" \
    sh -c 'runuser -u app -- gnucash --display=:0 --paths'
  echo "exit status: $status (gnucash --display=:0 --paths)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" == *"GNC_USERDATA_DIR: /config/"* ]]
}

@test "Checking Gnucash GNC_USERCONFIG_DIR points to /config..." {
  wait_for_container_daemon
  run docker exec "${CONTAINER_DAEMON_NAME}" \
    sh -c 'runuser -u app -- gnucash --display=:0 --paths'
  echo "exit status: $status (gnucash --display=:0 --paths)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" == *"GNC_USERCONFIG_DIR: /config/"* ]]
}

@test "Checking that Gnucash runs automatically after container start..." {
  wait_for_container_daemon
  run docker exec "${CONTAINER_DAEMON_NAME}" pgrep gnucash
  echo "exit status: $status (pgrep gnucash)"
  [ "$status" -eq 0 ]
}
