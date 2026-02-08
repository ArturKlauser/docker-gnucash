load utils_common
load utils_container

# Load bats support libraries.
bats_load_library 'bats-support'
bats_load_library 'bats-assert'
bats_load_library 'bats-file'

setup_all() {
  setup_common
  setup_container_daemon
}

teardown_all() {
  teardown_container_daemon
  teardown_common
}
