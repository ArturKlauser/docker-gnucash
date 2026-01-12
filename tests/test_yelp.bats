#!/bin/env bats

load 'setup_suite.bash'

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
