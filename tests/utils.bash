load setup_common
load setup_container_daemon

load teardown_common
load teardown_container_daemon

setup_all() {
  setup_common
  setup_container_daemon
}

teardown_all() {
  teardown_container_daemon
  teardown_common
}
