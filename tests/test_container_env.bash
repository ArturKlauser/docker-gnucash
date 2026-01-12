#---
# Container wide environment variables; set in image
#---

@test "Checking APP_NAME container environment variable..." {
  # Container-wide variable; we don't need to wait for gnucash to start.
  run exec_in_container printenv APP_NAME
  echo "exit status: $status (printenv APP_NAME)"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [ "${lines[0]}" = "GnuCash" ]
}

@test "Checking SECURE_CONNECTION container environment variable..." {
  # Container-wide variable; we don't need to wait for gnucash to start.
  run exec_in_container printenv SECURE_CONNECTION
  echo "exit status: $status (printenv SECURE_CONNECTION)"
  [ "$status" -eq 0 ]  # Environment variable could not be retrieved
  echo "lines[0]: ${lines[0]}"
  [ "${lines[0]}" = "1" ]
}
