#---
# Gnucash process environment variables; set during container startup
#---

@test "Checking XDG_CONFIG_HOME gnucash environment variable points to /config..." {
  get_app_env_var 'XDG_CONFIG_HOME'
  echo "exit status: $status (get_app_env_var 'XDG_CONFIG_HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_DATA_HOME gnucash environment variable points to /config..." {
  get_app_env_var 'XDG_DATA_HOME'
  echo "exit status: $status (get_app_env_var 'XDG_DATA_HOME')"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "/config/"* ]]
}

@test "Checking XDG_CACHE_HOME gnucash environment variable points to /config..." {
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
