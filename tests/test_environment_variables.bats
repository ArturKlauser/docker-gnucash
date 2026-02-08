#!/bin/env bats

load utils

#---
# Container wide environment variables; set in image
#---

@test "Checking APP_NAME container environment variable..." {
  # Container-wide variable; we don't need to wait for gnucash to start.
  run exec_in_container printenv APP_NAME
  assert_success
  assert_line --index 0 "GnuCash"
}

@test "Checking SECURE_CONNECTION container environment variable..." {
  # Container-wide variable; we don't need to wait for gnucash to start.
  run exec_in_container printenv SECURE_CONNECTION
  assert_success
  assert_line --index 0 "1"
}

#---
# Gnucash process environment variables; set during container startup
#---

@test "Checking XDG_CONFIG_HOME points to /config" {
  get_app_env_var 'XDG_CONFIG_HOME'
  assert_success
  assert_line --index 0 --partial "/config/"
}

@test "Checking XDG_DATA_HOME points to /config" {
  get_app_env_var 'XDG_DATA_HOME'
  assert_success
  assert_line --index 0 --partial "/config/"
}

@test "Checking XDG_CACHE_HOME points to /config" {
  get_app_env_var 'XDG_CACHE_HOME'
  assert_success
  assert_line --index 0 --partial "/config/"
}

@test "Checking HOME gnucash environment variable points to /data..." {
  get_app_env_var 'HOME'
  assert_success
  assert_line --index 0 "/data"
}
