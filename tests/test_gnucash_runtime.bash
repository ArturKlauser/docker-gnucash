@test "Checking that Gnucash runs..." {
  # Modern Gnucash can't even print verion or help messages to the TTY if it
  # can't pass it's GTK GUI startup. That only works if a display is set and
  # an X-server is actually running there. So we have to wait for the whole
  # container to start up before we can test even the most basic gnucash
  # invocation.
  run exec_in_container sh -c 'gnucash --display=:0 --version'
  echo "exit status: $status (gnucash --display=:0 --version)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" =~ "GnuCash "[0-9]+\.[0-9]+ ]]
}

# To get the GNC_* variables that the installed gnucash app is using, we need
# to run 'gnucach --paths' in the environment context that the already started
# gnucash process is operating in.

@test "Checking Gnucash GNC_USERDATA_DIR points to /config..." {
  run exec_in_container_app_env gnucash --display=:0 --paths
  echo "exit status: $status (gnucash --display=:0 --paths)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" == *"GNC_USERDATA_DIR: /config/"* ]]
}

@test "Checking Gnucash GNC_USERCONFIG_DIR points to /config..." {
  run exec_in_container_app_env gnucash --display=:0 --paths
  echo "exit status: $status (gnucash --display=:0 --paths)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" == *"GNC_USERCONFIG_DIR: /config/"* ]]
}

@test "Checking that Gnucash runs automatically after container start..." {
  run exec_in_container pgrep -P 1 gnucash
  echo "exit status: $status (pgrep -P 1 gnucash)"
  [ "$status" -eq 0 ]
}
