#!/bin/env bats

load utils

@test "Checking that app web icons are installed..." {
  icon_dir='/opt/noVNC/app/images/icons'
  run exec_in_container test -d "${icon_dir}"
  assert_success # icons exists
  run exec_in_container test -e "${icon_dir}/favicon.ico"
  assert_success # web favicon exists
}
