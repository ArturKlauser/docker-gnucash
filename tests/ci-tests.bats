#!/bin/env bats

load utils

setup_file() {
  setup_all
}

teardown_file() {
  teardown_all
}

# ---
# The tests below don't need the gnucash application to be running.
# ---
load test_container_env
load test_finance_quote
load test_gnucash_installation
load test_gnucash_docs
load test_icons
load test_yelp

# ---
# The tests below need the gnucash application to be running.
# ---
@test "Waiting for container daemon to be ready..." {
  wait_for_container_daemon
}
load test_app_env
load test_gnucash_runtime
load test_mapped_volumes

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

@test "Checking that Finance::Quote Perl module is installed..." {
  run exec_in_container perl -mFinance::Quote -e 1
  echo "exit status: $status (perl -mFinance::Quote -e 1)"
  [ "$status" -eq 0 ]
}

@test "Checking that Gnucash integration with Finance::Quote works..." {
  run exec_in_container gnucash-cli --quotes info
  echo "exit status: $status (gnucash-cli --quotes info)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" =~ "Finance::Quote version "[0-9]+\.[0-9]+ ]]
}

@test "Checking that /startapp.sh exists..." {
  run exec_in_container test -f /startapp.sh
  echo "exit status: $status (test -f /startapp.sh)"
  [ "$status" -eq 0 ]
}

@test "Checking that /startapp.sh has execute permissions..." {
  run exec_in_container test -x /startapp.sh
  echo "exit status: $status (test -x /startapp.sh)"
  [ "$status" -eq 0 ]
}

@test "Checking that Gnucash is installed..." {
  run exec_in_container which gnucash
  echo "exit status: $status (which gnucash)"
  [ "$status" -eq 0 ]
  run exec_in_container test -x "${lines[0]}"
  echo "exit status: $status (test -x \"${lines[0]}\")"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash documentation is installed..." {
  run exec_in_container test -d /usr/share/doc/gnucash-docs
  echo "exit status: $status (test -d /usr/share/doc/gnucash-docs)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash guide directory exists..." {
  run exec_in_container test -d /usr/share/help/C/gnucash-guide
  echo "exit status: $status (test -d /usr/share/help/C/gnucash-guide)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash guide index exists..." {
  run exec_in_container test -f /usr/share/help/C/gnucash-guide/index.docbook
  echo "exit status: $status (test -f /usr/share/help/C/gnucash-guide/index.docbook)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash guide contains XML files..." {
  # *.xml needs to be quoted to prevent host shell from expanding it.
  run exec_in_container sh -c 'ls /usr/share/help/C/gnucash-guide/*.xml'
  echo "exit status: $status (ls /usr/share/help/C/gnucash-guide/*.xml)"
  [ "$status" -eq 0 ]
}
@test "Checking that GnuCash manual directory exists..." {
  run exec_in_container test -d /usr/share/help/C/gnucash-manual
  echo "exit status: $status (test -d /usr/share/help/C/gnucash-manual)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash manual index exists..." {
  run exec_in_container test -f /usr/share/help/C/gnucash-manual/index.docbook
  echo "exit status: $status (test -f /usr/share/help/C/gnucash-manual/index.docbook)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash manual contains XML files..." {
  # *.xml needs to be quoted to prevent host shell from expanding it.
  run exec_in_container sh -c 'ls /usr/share/help/C/gnucash-manual/*.xml'
  echo "exit status: $status (ls /usr/share/help/C/gnucash-manual/*.xml)"
  [ "$status" -eq 0 ]
}

@test "Checking that app web icons are installed..." {
  icon_dir='/opt/noVNC/app/images/icons'
  run exec_in_container test -d "${icon_dir}"
  echo "exit status: $status (test -d \"${icon_dir}\")"
  [ "$status" -eq  0 ]  # icons exists
  run exec_in_container test -e "${icon_dir}/favicon.ico"
  echo "exit status: $status (test -e \"${icon_dir}/favicon.ico\")"
  [ "$status" -eq  0 ]  # web favicon exists
}

@test "Checking that yelp is installed..." {
  run exec_in_container which yelp
  echo "exit status: $status (which yelp)"
  [ "$status" -eq 0 ]
  yelp_app="${lines[0]}"
  run exec_in_container test -x "${yelp_app}"
  echo "exit status: $status (test -x \"${yelp_app}\")"
  [ "$status" -eq 0 ]
}

@test "Checking that yelp runs..." {
  run exec_in_container yelp -h
  echo "exit status: $status (yelp -h)"
  [ "$status" -eq 0 ]
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "Usage:"* ]]
}

@test "Waiting for container daemon to be ready..." {
  wait_for_container_daemon
}

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

@test "Checking that /config directory exists and is owned by app user/group..." {
  # Permissions of imported volumes are adjusted during startup, so we have to
  # wait for this to happen before checking.
  run exec_in_container runuser -u app -- test -e /config
  echo "exit status: $status (runuser -u app -- test -e /config)"
  [ "$status" -eq  0 ]  # /config exists
  run exec_in_container runuser -u app -- test -d /config
  echo "exit status: $status (runuser -u app -- test -d /config)"
  [ "$status" -eq  0 ]  # /config is a directory
  run exec_in_container runuser -u app -- test -O /config
  echo "exit status: $status (runuser -u app -- test -O /config)"
  [ "$status" -eq  0 ]  # app user owns /config
  run exec_in_container runuser -u app -- test -G /config
  echo "exit status: $status (runuser -u app -- test -G /config)"
  [ "$status" -eq  0 ]  # app group owns /config
}

@test "Checking that /data directory exists and is owned by app user/group..." {
  run exec_in_container runuser -u app -- test -e /data
  echo "exit status: $status (runuser -u app -- test -e /data)"
  [ "$status" -eq  0 ]  # /data exists
  run exec_in_container runuser -u app -- test -d /data
  echo "exit status: $status (runuser -u app -- test -d /data)"
  [ "$status" -eq  0 ]  # /data is a directory
  run exec_in_container runuser -u app -- test -O /data
  echo "exit status: $status (runuser -u app -- test -O /data)"
  [ "$status" -eq  0 ]  # app user owns /data
  run exec_in_container runuser -u app -- test -G /data
  echo "exit status: $status (runuser -u app -- test -G /data)"
  [ "$status" -eq  0 ]  # app group owns /data
}

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

@test "Checking that Finance::Quote Perl module is installed..." {
  run exec_in_container perl -mFinance::Quote -e 1
  echo "exit status: $status (perl -mFinance::Quote -e 1)"
  [ "$status" -eq 0 ]
}

@test "Checking that Gnucash integration with Finance::Quote works..." {
  run exec_in_container gnucash-cli --quotes info
  echo "exit status: $status (gnucash-cli --quotes info)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" =~ "Finance::Quote version "[0-9]+\.[0-9]+ ]]
}

@test "Checking that /startapp.sh exists..." {
  run exec_in_container test -f /startapp.sh
  echo "exit status: $status (test -f /startapp.sh)"
  [ "$status" -eq 0 ]
}

@test "Checking that /startapp.sh has execute permissions..." {
  run exec_in_container test -x /startapp.sh
  echo "exit status: $status (test -x /startapp.sh)"
  [ "$status" -eq 0 ]
}

@test "Checking that Gnucash is installed..." {
  run exec_in_container which gnucash
  echo "exit status: $status (which gnucash)"
  [ "$status" -eq 0 ]
  run exec_in_container test -x "${lines[0]}"
  echo "exit status: $status (test -x \"${lines[0]}\")"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash documentation is installed..." {
  run exec_in_container test -d /usr/share/doc/gnucash-docs
  echo "exit status: $status (test -d /usr/share/doc/gnucash-docs)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash guide directory exists..." {
  run exec_in_container test -d /usr/share/help/C/gnucash-guide
  echo "exit status: $status (test -d /usr/share/help/C/gnucash-guide)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash guide index exists..." {
  run exec_in_container test -f /usr/share/help/C/gnucash-guide/index.docbook
  echo "exit status: $status (test -f /usr/share/help/C/gnucash-guide/index.docbook)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash guide contains XML files..." {
  # *.xml needs to be quoted to prevent host shell from expanding it.
  run exec_in_container sh -c 'ls /usr/share/help/C/gnucash-guide/*.xml'
  echo "exit status: $status (ls /usr/share/help/C/gnucash-guide/*.xml)"
  [ "$status" -eq 0 ]
}
@test "Checking that GnuCash manual directory exists..." {
  run exec_in_container test -d /usr/share/help/C/gnucash-manual
  echo "exit status: $status (test -d /usr/share/help/C/gnucash-manual)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash manual index exists..." {
  run exec_in_container test -f /usr/share/help/C/gnucash-manual/index.docbook
  echo "exit status: $status (test -f /usr/share/help/C/gnucash-manual/index.docbook)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash manual contains XML files..." {
  # *.xml needs to be quoted to prevent host shell from expanding it.
  run exec_in_container sh -c 'ls /usr/share/help/C/gnucash-manual/*.xml'
  echo "exit status: $status (ls /usr/share/help/C/gnucash-manual/*.xml)"
  [ "$status" -eq 0 ]
}

@test "Checking that app web icons are installed..." {
  icon_dir='/opt/noVNC/app/images/icons'
  run exec_in_container test -d "${icon_dir}"
  echo "exit status: $status (test -d \"${icon_dir}\")"
  [ "$status" -eq  0 ]  # icons exists
  run exec_in_container test -e "${icon_dir}/favicon.ico"
  echo "exit status: $status (test -e \"${icon_dir}/favicon.ico\")"
  [ "$status" -eq  0 ]  # web favicon exists
}

@test "Checking that yelp is installed..." {
  run exec_in_container which yelp
  echo "exit status: $status (which yelp)"
  [ "$status" -eq 0 ]
  yelp_app="${lines[0]}"
  run exec_in_container test -x "${yelp_app}"
  echo "exit status: $status (test -x \"${yelp_app}\")"
  [ "$status" -eq 0 ]
}

@test "Checking that yelp runs..." {
  run exec_in_container yelp -h
  echo "exit status: $status (yelp -h)"
  [ "$status" -eq 0 ]
  echo "lines[0]: ${lines[0]}"
  [[ "${lines[0]}" == "Usage:"* ]]
}

@test "Waiting for container daemon to be ready..." {
  wait_for_container_daemon
}

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

@test "Checking that /config directory exists and is owned by app user/group..." {
  # Permissions of imported volumes are adjusted during startup, so we have to
  # wait for this to happen before checking.
  run exec_in_container runuser -u app -- test -e /config
  echo "exit status: $status (runuser -u app -- test -e /config)"
  [ "$status" -eq  0 ]  # /config exists
  run exec_in_container runuser -u app -- test -d /config
  echo "exit status: $status (runuser -u app -- test -d /config)"
  [ "$status" -eq  0 ]  # /config is a directory
  run exec_in_container runuser -u app -- test -O /config
  echo "exit status: $status (runuser -u app -- test -O /config)"
  [ "$status" -eq  0 ]  # app user owns /config
  run exec_in_container runuser -u app -- test -G /config
  echo "exit status: $status (runuser -u app -- test -G /config)"
  [ "$status" -eq  0 ]  # app group owns /config
}

@test "Checking that /data directory exists and is owned by app user/group..." {
  run exec_in_container runuser -u app -- test -e /data
  echo "exit status: $status (runuser -u app -- test -e /data)"
  [ "$status" -eq  0 ]  # /data exists
  run exec_in_container runuser -u app -- test -d /data
  echo "exit status: $status (runuser -u app -- test -d /data)"
  [ "$status" -eq  0 ]  # /data is a directory
  run exec_in_container runuser -u app -- test -O /data
  echo "exit status: $status (runuser -u app -- test -O /data)"
  [ "$status" -eq  0 ]  # app user owns /data
  run exec_in_container runuser -u app -- test -G /data
  echo "exit status: $status (runuser -u app -- test -G /data)"
  [ "$status" -eq  0 ]  # app group owns /data
}
