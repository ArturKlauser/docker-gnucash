#!/bin/env bats

load utils

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
  echo "exit status: $status" \
       "(test -f /usr/share/help/C/gnucash-guide/index.docbook)"
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
  echo "exit status: $status" \
       "(test -f /usr/share/help/C/gnucash-manual/index.docbook)"
  [ "$status" -eq 0 ]
}

@test "Checking that GnuCash manual contains XML files..." {
  # *.xml needs to be quoted to prevent host shell from expanding it.
  run exec_in_container sh -c 'ls /usr/share/help/C/gnucash-manual/*.xml'
  echo "exit status: $status (ls /usr/share/help/C/gnucash-manual/*.xml)"
  [ "$status" -eq 0 ]
}
