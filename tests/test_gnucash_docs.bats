#!/bin/env bats

setup() {
    load setup_common
    load setup_container_daemon
}

teardown() {
    load teardown_container_daemon
    load teardown_common
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
    run docker exec "${CONTAINER_DAEMON_NAME}" ls /usr/share/help/C/gnucash-guide/*.xml
    [ "$status" -eq 0 ]
}
