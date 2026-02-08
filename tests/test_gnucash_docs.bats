#!/bin/env bats

load utils

@test "Checking that GnuCash documentation is installed..." {
  run exec_in_container test -d /usr/share/doc/gnucash-docs
  assert_success
}

@test "Checking that GnuCash guide directory exists..." {
  run exec_in_container test -d /usr/share/help/C/gnucash-guide
  assert_success
}

@test "Checking that GnuCash guide index exists..." {
  run exec_in_container test -f /usr/share/help/C/gnucash-guide/index.docbook
  assert_success
}

@test "Checking that GnuCash guide contains XML/docbook files..." {
  # *.xml needs to be quoted to prevent host shell from expanding it.
  run exec_in_container sh -c \
    'ls -1 /usr/share/help/C/gnucash-guide/ | grep -Ec "\.(xml|docbook)$"'
  assert_success
  # Currently there are 26 files - expect some variation with versions.
  [[ "${lines[0]}" -ge '20' ]]
}

@test "Checking that GnuCash manual directory exists..." {
  run exec_in_container test -d /usr/share/help/C/gnucash-manual
  assert_success
}

@test "Checking that GnuCash manual index exists..." {
  run exec_in_container test -f /usr/share/help/C/gnucash-manual/index.docbook
  assert_success
}

@test "Checking that GnuCash manual contains XML/docbook files..." {
  # *.xml needs to be quoted to prevent host shell from expanding it.
  run exec_in_container sh -c \
    'ls -1 /usr/share/help/C/gnucash-manual/ | grep -Ec "\.(xml|docbook)$"'
  assert_success
  # Currently there are 18 files - expect some variation with versions.
  [[ "${lines[0]}" -ge '12' ]]
}
