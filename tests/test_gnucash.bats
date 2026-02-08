#!/bin/env bats

load utils

@test "Checking that /startapp.sh exists..." {
  run exec_in_container test -f /startapp.sh
  assert_success
}

@test "Checking that /startapp.sh has execute permissions..." {
  run exec_in_container test -x /startapp.sh
  assert_success
}

@test "Checking that Gnucash is installed..." {
  run exec_in_container which gnucash
  assert_success
  run exec_in_container test -x "${lines[0]}"
  assert_success
}

@test "Checking that Gnucash runs..." {
  # Modern Gnucash can't even print version or help messages to the TTY if it
  # can't pass its GTK GUI startup. That only works if a display is set and
  # an X-server is actually running there. So we have to wait for the whole
  # container to start up before we can test even the most basic gnucash
  # invocation.
  wait_for_container_daemon
  run exec_in_container sh -c 'gnucash --display=:0 --version'
  assert_success
  assert_output --regexp "GnuCash [0-9]+\.[0-9]+"
}

# To get the GNC_* variables that the installed gnucash app is using, we need
# to run 'gnucash --paths' in the environment context that the already started
# gnucash process is operating in.

@test "Checking Gnucash GNC_DATA_HOME points to /config..." {
  run exec_in_container_app_env gnucash --display=:0 --paths
  assert_success
  assert_line --regexp "^GNC_DATA_HOME: /config/"
}

@test "Checking Gnucash GNC_CONFIG_HOME points to /config..." {
  run exec_in_container_app_env gnucash --display=:0 --paths
  assert_success
  assert_line --regexp "^GNC_CONFIG_HOME: /config/"
}

@test "Checking that Gnucash runs automatically after container start..." {
  wait_for_container_daemon
  run exec_in_container pgrep -P 1 gnucash
  assert_success
}
