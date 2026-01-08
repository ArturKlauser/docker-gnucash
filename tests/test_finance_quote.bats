#!/bin/env bats

load utils

setup_file() {
  setup_all
}

teardown_file() {
  teardown_all
}

@test "Checking that Finance::Quote Perl module is installed..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" perl -mFinance::Quote -e 1
  echo "exit status: $status (perl -mFinance::Quote -e 1)"
  [ "$status" -eq 0 ]
}

@test "Checking that Gnucash integration with Finance::Quote works..." {
  run docker exec "${CONTAINER_DAEMON_NAME}" gnucash-cli --quotes info
  echo "exit status: $status (gnucash-cli --quotes info)"
  [ "$status" -eq 0 ]
  echo "output: ${output}"
  [[ "${output}" =~ "Finance::Quote version "[0-9]+\.[0-9]+ ]]
}

# We intentionally don't test the actual quote retrieval. During time of test we
# don't want to depend on remote servers which over the past have shown various
# degrees of instability, authorization, and quota issue.
