#!/bin/env bats

load utils

setup_file() {
  setup_all
}

teardown_file() {
  teardown_all
}

#---
# Container wide environment variables; set in image
#---

@test "Checking APP_NAME container environment variable..." {
  # Container-wide variable; we don't need to wait for gnucash to start.
  run docker exec "${CONTAINER_DAEMON_NAME}" printenv APP_NAME
  echo "exit status: $status (printenv APP_NAME)"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [ "${lines[0]}" = "GnuCash" ]
}

@test "Checking SECURE_CONNECTION container environment variable..." {
  # Container-wide variable; we don't need to wait for gnucash to start.
  run docker exec "${CONTAINER_DAEMON_NAME}" printenv SECURE_CONNECTION
  echo "exit status: $status (printenv SECURE_CONNECTION)"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [ "${lines[0]}" = "1" ]
}

#---
# Gnucash process environment variables; set during container startup
#---

# Get an environment variable from the environment of the running gnucash app.
get_gnucash_env() {
  local name=$1

  # We must wait for gnucash to have started to see its environment.
  wait_for_container_daemon

  run docker exec "${CONTAINER_DAEMON_NAME}" \
    sh -c 'runuser -u app cat "/proc/$(pgrep gnucash)/environ" \
             | tr "\0" "\n" | grep "^'${name}'="'
  echo ${output}  # Helps debugging env errors
  run sh -c "echo ${output} | sed -e 's/^${name}=//'"
}

@test "Checking XDG_CONFIG_HOME gnucash environment variable points to /config..." {
  get_gnucash_env 'XDG_CONFIG_HOME'
  echo "exit status: $status (get_gnucash_env 'XDG_CONFIG_HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_DATA_HOME gnucash environment variable points to /config..." {
  get_gnucash_env 'XDG_DATA_HOME'
  echo "exit status: $status (get_gnucash_env 'XDG_DATA_HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_CACHE_HOME gnucash environment variable points to /config..." {
  get_gnucash_env  'XDG_CACHE_HOME'
  echo "exit status: $status (get_gnucash_env 'XDG_CACHE_HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking HOME gnucash environment variable points to /data..." {
  get_gnucash_env 'HOME'
  echo "exit status: $status (get_gnucash_env 'HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [ "${lines[0]}" = "/data" ]
}
