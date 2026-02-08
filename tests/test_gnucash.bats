#!/bin/env bats

load utils

@test "Checking that /startapp.sh exists..." {
  run exec_in_container test -f /startapp.sh
  echo "exit status: ${status} (test -f /startapp.sh)"
  [[ "${status}" -eq 0 ]]
}

@test "Checking that /startapp.sh has execute permissions..." {
  run exec_in_container test -x /startapp.sh
  echo "exit status: ${status} (test -x /startapp.sh)"
  [[ "${status}" -eq 0 ]]
}

@test "Checking that Gnucash is installed..." {
  run exec_in_container which gnucash
  echo "exit status: ${status} (which gnucash)"
  [[ "${status}" -eq 0 ]]
  run exec_in_container test -x "${lines[0]}"
  echo "exit status: ${status} (test -x \"${lines[0]}\")"
  [[ "${status}" -eq 0 ]]
}

@test "Checking that Gnucash runs..." {
  # Modern Gnucash can't even print version or help messages to the TTY if it
  # can't pass its GTK GUI startup. That only works if a display is set and
  # an X-server is actually running there. So we have to wait for the whole
  # container to start up before we can test even the most basic gnucash
  # invocation.
  wait_for_container_daemon
  run exec_in_container sh -c 'gnucash --display=:0 --version'
  echo "exit status: ${status} (gnucash --display=:0 --version)"
  [[ "${status}" -eq 0 ]]
  echo "output: ${output}"
  [[ "${output}" =~ "GnuCash "[0-9]+\.[0-9]+ ]]
}

# To get the GNC_* variables that the installed gnucash app is using, we need
# to run 'gnucash --paths' in the environment context that the already started
# gnucash process is operating in.

@test "Checking Gnucash GNC_DATA_HOME points to /config..." {
  run exec_in_container_app_env gnucash --display=:0 --paths
  echo "exit status: ${status} (gnucash --display=:0 --paths)"
  [[ "${status}" -eq 0 ]]
  echo "output: ${output}"
  [[ "${output}" == *"GNC_DATA_HOME: /config/"* ]]
}

@test "Checking Gnucash GNC_CONFIG_HOME points to /config..." {
  run exec_in_container_app_env gnucash --display=:0 --paths
  echo "exit status: ${status} (gnucash --display=:0 --paths)"
  [[ "${status}" -eq 0 ]]
  echo "output: ${output}"
  [[ "${output}" == *"GNC_CONFIG_HOME: /config/"* ]]
}

@test "Checking that Gnucash runs automatically after container start..." {
  wait_for_container_daemon
  run exec_in_container pgrep -P 1 gnucash
  echo "exit status: ${status} (pgrep -P 1 gnucash)"
  [[ "${status}" -eq 0 ]]
}
