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
