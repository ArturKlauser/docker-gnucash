teardown_container_daemon() {
  [ -n "$CONTAINER_DAEMON_NAME" ]

  echo "Stopping docker container..."
  # We kill instead of stop the container since in the test environment we don't
  # care about a clean container shutdown and prefer speedy test execution.
  docker kill "$CONTAINER_DAEMON_NAME"

  echo "Removing docker container..."
  docker rm "$CONTAINER_DAEMON_NAME"

  # Clear the container ID.
  unset CONTAINER_DAEMON_NAME
}
