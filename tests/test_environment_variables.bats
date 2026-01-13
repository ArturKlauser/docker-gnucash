#!/bin/env bats

load utils

#---
# Container wide environment variables; set in image
#---

@test "Checking APP_NAME container environment variable..." {
  # Container-wide variable; we don't need to wait for gnucash to start.
  run exec_in_container printenv APP_NAME
  echo "exit status: $status (printenv APP_NAME)"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [ "${lines[0]}" = "GnuCash" ]
}

@test "Checking SECURE_CONNECTION container environment variable..." {
  # Container-wide variable; we don't need to wait for gnucash to start.
  run exec_in_container printenv SECURE_CONNECTION
  echo "exit status: $status (printenv SECURE_CONNECTION)"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [ "${lines[0]}" = "1" ]
}

#---
# Gnucash process environment variables; set during container startup
#---

@test "Checking XDG_CONFIG_HOME points to /config" {
  get_app_env_var 'XDG_CONFIG_HOME'
  echo "exit status: $status (get_app_env_var 'XDG_CONFIG_HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_DATA_HOME points to /config" {
  get_app_env_var 'XDG_DATA_HOME'
  echo "exit status: $status (get_app_env_var 'XDG_DATA_HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_CACHE_HOME points to /config" {
  get_app_env_var  'XDG_CACHE_HOME'
  echo "exit status: $status (get_app_env_var 'XDG_CACHE_HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking HOME gnucash environment variable points to /data..." {
  get_app_env_var 'HOME'
  echo "exit status: $status (get_app_env_var 'HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [ "${lines[0]}" = "/data" ]
}
