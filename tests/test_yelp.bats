#!/bin/env bats

load utils

@test "Checking that yelp is installed..." {
  exec_in_container which yelp
  assert_success
  yelp_app="${lines[0]}"
  exec_in_container test -x "${yelp_app}"
  assert_success
}

@test "Checking that yelp runs..." {
  exec_in_container yelp -h
  assert_success
  assert_line --index 0 --regexp "^Usage:.*"
}
