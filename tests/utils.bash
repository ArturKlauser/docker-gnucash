load utils_common
load utils_container

setup_all() {
  setup_common
  setup_container_daemon
}

teardown_all() {
  teardown_container_daemon
  teardown_common
}
