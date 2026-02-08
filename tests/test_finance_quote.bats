#!/bin/env bats

load utils

@test "Checking that Finance::Quote Perl module is installed..." {
  exec_in_container perl -mFinance::Quote -e 1
  assert_success
}

@test "Checking that Gnucash integration with Finance::Quote works..." {
  exec_in_container gnucash-cli --quotes info
  assert_success
  assert_output --regexp "Finance::Quote version [0-9]+\.[0-9]+"
}

# We intentionally don't test the actual quote retrieval. During time of test we
# don't want to depend on remote servers which over the past have shown various
# degrees of instability, authorization, and quota issues.
