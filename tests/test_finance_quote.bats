#!/bin/env bats

load utils

@test "Checking that Finance::Quote Perl module is installed..." {
  run exec_in_container perl -mFinance::Quote -e 1
  echo "exit status: $status (perl -mFinance::Quote -e 1)"
  [ "$status" -eq 0 ]
}

@test "Checking that Gnucash integration with Finance::Quote works..." {
  run exec_in_container gnucash-cli --quotes info
  echo "exit status: $status (gnucash-cli --quotes info)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" =~ "Finance::Quote version "[0-9]+\.[0-9]+ ]]
}

# We intentionally don't test the actual quote retrieval. During time of test we
# don't want to depend on remote servers which over the past have shown various
# degrees of instability, authorization, and quota issue.
