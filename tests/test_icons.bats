#!/bin/env bats

load 'setup_suite.bash'

@test "Checking that app web icons are installed..." {
  icon_dir='/opt/noVNC/app/images/icons'
  run exec_in_container test -d "${icon_dir}"
  echo "exit status: $status (test -d \"${icon_dir}\")"
  [ "$status" -eq  0 ]  # icons exists
  run exec_in_container test -e "${icon_dir}/favicon.ico"
  echo "exit status: $status (test -e \"${icon_dir}/favicon.ico\")"
  [ "$status" -eq  0 ]  # web favicon exists
}
