#!/bin/env bats

load utils

@test "Checking that Finance::Quote Perl module is installed..." {
  run exec_in_container perl -mFinance::Quote -e 1
  assert_success
}

@test "Checking that Gnucash integration with Finance::Quote works..." {
  run exec_in_container gnucash-cli --quotes info
  assert_success
  assert_output --partial "Finance::Quote version "
}

# We intentionally don't test the actual quote retrieval. During time of test we
# don't want to depend on remote servers which over the past have shown various
# degrees of instability, authorization, and quota issues.
