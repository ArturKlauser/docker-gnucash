#!/bin/env bats

load utils

setup_file() {
  setup_all
}

teardown_file() {
  teardown_all
}

@test "Checking that GnuCash documentation is installed..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" test -d /usr/share/doc/gnucash-docs
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash guide directory exists..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" test -d /usr/share/help/C/gnucash-guide
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash guide index exists..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" test -f /usr/share/help/C/gnucash-guide/index.docbook
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash guide contains XML files..." {
  # *.xml needs to be quoted to prevent host shell from expanding it.
  run docker exec "${CONTAINER_DAEMON_NAME}" sh -c 'ls /usr/share/help/C/gnucash-guide/*.xml'
  [ "$status" -eq 0 ]
}
@test "Checking that GnuCash manual directory exists..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" test -d /usr/share/help/C/gnucash-manual
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash manual index exists..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" test -f /usr/share/help/C/gnucash-manual/index.docbook
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash manual contains XML files..." {
  # *.xml needs to be quoted to prevent host shell from expanding it.
  run docker exec "${CONTAINER_DAEMON_NAME}" sh -c 'ls /usr/share/help/C/gnucash-manual/*.xml'
  [ "$status" -eq 0 ]
}
