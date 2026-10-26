#!/usr/bin/env bats

load utils

setup_file() {
  HOST_COM_DIR="$(mktemp -d)"
  export HOST_COM_DIR
  touch "${HOST_COM_DIR}/appready"
  cat << 'APPENV' > "${HOST_COM_DIR}/appenv"
FOO=bar
EMPTY_VAR=
EQUALS_VAR=some=value
PREFIX_VAR=wrong
VAR=correct
APPENV
}

teardown_file() {
  rm -rf "${HOST_COM_DIR}"
}

# Note: get_app_env_var internally uses 'run echo', so we invoke it directly
# rather than wrapping it in 'run' to properly assert against '$output'.

@test "get_app_env_var: normal variable" {
  get_app_env_var "FOO"
  assert_success
  assert_output "bar"
}

@test "get_app_env_var: empty variable" {
  get_app_env_var "EMPTY_VAR"
  assert_success
  assert_output ""
}

@test "get_app_env_var: exact key match" {
  get_app_env_var "VAR"
  assert_success
  assert_output "correct"
}

@test "get_app_env_var: values with equals signs" {
  get_app_env_var "EQUALS_VAR"
  assert_success
  assert_output "some=value"
}
