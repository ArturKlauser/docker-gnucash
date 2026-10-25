#!/bin/env bats

load utils

setup_file() {
  # Stub setup_file to prevent suite-level setup starting docker when we just run this file locally.
  :
}

setup() {
  # Create a dummy config file
  export CONFIG_FILE="${BATS_TEST_TMPDIR}/oauth2-proxy.cfg"

  cat << 'CFG' > "${CONFIG_FILE}"
# dummy config
client_id = "12345"
  client_secret = "secret678"
    cookie_secret = "my_cookie_secret"

# tight spacing
tight="tight_val"

# spaced out
spaced   =   "spaced_val"
CFG

  # Source the functions from the script
  # We need to stub some things because the script has top-level execution
  # which we don't want to run
  source <(sed -n '/^get_value_unquoted()/,/^}/p;/^set_value_quoted()/,/^}/p' docker/rootfs/opt/with-oauth2-proxy/etc/cont-init.d/50-oauth2-proxy.sh)
}

@test "get_value_unquoted retrieves value without quotes" {
  run get_value_unquoted "client_id"
  assert_success
  assert_line --index 0 "12345"

  run get_value_unquoted "client_secret"
  assert_success
  assert_line --index 0 "secret678"
}

@test "get_value_unquoted handles different spacing" {
  run get_value_unquoted "tight"
  assert_success
  assert_line --index 0 "tight_val"

  run get_value_unquoted "spaced"
  assert_success
  assert_line --index 0 "spaced_val"
}

@test "get_value_unquoted returns nothing for missing key" {
  run get_value_unquoted "missing_key"
  assert_success
  refute_output
}

@test "set_value_quoted sets value with quotes and retains spacing format before equals" {
  run set_value_quoted "client_id" "new_id_999"
  assert_success

  run get_value_unquoted "client_id"
  assert_success
  assert_line --index 0 "new_id_999"

  # verify file content explicitly
  run grep "client_id" "${CONFIG_FILE}"
  assert_success
  assert_line --regexp 'client_id = "new_id_999"'
}

@test "set_value_quoted modifies existing key regardless of spacing" {
  run set_value_quoted "tight" "new_tight"
  assert_success

  # Note: The implementation adds a space after the equals sign
  run grep "tight" "${CONFIG_FILE}"
  assert_success
  assert_line --regexp 'tight= "new_tight"'

  run set_value_quoted "spaced" "new_spaced"
  assert_success

  run grep "spaced" "${CONFIG_FILE}"
  assert_success
  assert_line --regexp 'spaced   = "new_spaced"'
}
