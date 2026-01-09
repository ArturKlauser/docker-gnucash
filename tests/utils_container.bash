setup_container_daemon() {
  export CONTAINER_DAEMON_NAME="$(mktemp -u dockertest-XXXXXXXXXX)"

  # Make sure there is no existing instance.
  docker kill "$CONTAINER_DAEMON_NAME" >/dev/null 2>&1 \
    && docker rm "$CONTAINER_DAEMON_NAME" >/dev/null 2>&1 || true

  # Create a service for testing that runs after the 'app' service in order to
  # notify us that the 'app' has been started.
  NOTIFIER_DIR="${TESTS_WORKDIR}/service.d/appready"
  mkdir -p "${NOTIFIER_DIR}"
  touch "${NOTIFIER_DIR}/app.dep"
  cat << EOF > "${NOTIFIER_DIR}/run"
#!/bin/sh
# Give app run script some time to exec gnucash process.
for i in {1..10}; do
  # Only care about gnucash child process of PID 1 (init),
  # not other random gnucash invocations from parallel tests.
  gnucash_pid=\$(pgrep -P 1 gnucash)
  [ -n "\$gnucash_pid" ] && break
  sleep 1
done
cat "/proc/\$gnucash_pid/environ" 2>&1 | tr '\0' '\n' > '/tmp/appenv'
touch '/tmp/appready'
EOF
  chmod 755 "${NOTIFIER_DIR}/run"
  # The 'appready' service is not started unless the 'default' service
  # (transitively) depends on it, so we have to add that dependence too.
  DEFAULT_DIR="${TESTS_WORKDIR}/service.d/default"
  mkdir -p "${DEFAULT_DIR}"
  touch "${DEFAULT_DIR}/appready.dep"

  # Start the container in daemon mode.
  run docker run \
    -d \
    --name "$CONTAINER_DAEMON_NAME" \
    -e USER_ID="$(id -u)" \
    -e GROUP_ID="$(id -g)" \
    -v "${NOTIFIER_DIR}:/etc/services.d/appready" \
    -v "${DEFAULT_DIR}/appready.dep:/etc/services.d/default/appready.dep" \
    "${DOCKER_EXTRA_OPTS[@]}" \
    "${DOCKER_IMAGE}" \
    "${DOCKER_CMD[@]}" \
    2>/dev/null
  [ "$status" -eq 0 ] || force_error "docker command failure: $output"
}

teardown_container_daemon() {
  [ -n "$CONTAINER_DAEMON_NAME" ]

  echo "Stopping docker container..."
  # We kill instead of stop the container since in the test environment we
  # don't care about a clean container shutdown and prefer speedy test
  # execution.
  docker kill "$CONTAINER_DAEMON_NAME"

  echo "Removing docker container..."
  docker rm "$CONTAINER_DAEMON_NAME"

  # Clear the container ID.
  unset CONTAINER_DAEMON_NAME
}

# Execute command in container.
exec_in_container() {
  [ -n "$CONTAINER_DAEMON_NAME" ]
  docker exec "$CONTAINER_DAEMON_NAME" "$@"
}

getlog_container_daemon() {
  [ -n "$CONTAINER_DAEMON_NAME" ]
  docker logs -t "$CONTAINER_DAEMON_NAME"
}

wait_for_container_daemon() {
  echo "Waiting for the docker container daemon to be ready..."
  TIMEOUT=60
  while [ "$TIMEOUT" -ne 0 ]; do
    run exec_in_container sh -c "[ -f /tmp/appready ]"
    if [ "$status" -eq 0 ]; then
      break
    fi
    echo "waiting $TIMEOUT..."
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
  done

  if [ "$TIMEOUT" -eq 0 ]; then
    echo "Docker container daemon wait timeout."
    echo "====================================================================="
    echo " DOCKER LOGS"
    echo "====================================================================="
    getlog_container_daemon
    echo "====================================================================="
    echo " END DOCKER LOGS"
    echo "====================================================================="
    false
  else
    echo "Docker container ready."
  fi
}

# Get an environment variable from the environment of the running app.
get_app_env_var() {
  local name=$1

  # We must wait for the container to have started to see the app environment.
  wait_for_container_daemon

  run exec_in_container sh -c 'grep "^'${name}'=" "/tmp/appenv"'
  echo ${output}  # Helps debugging env errors
  run sh -c "echo ${output} | sed -e 's/^${name}=//'"
}

# Execute command in container app environment.
exec_in_container_app_env() {
  wait_for_container_daemon
  run exec_in_container cat '/tmp/appenv'
  echo "app_env:" "${lines[@]}"
  exec_in_container env "${lines[@]}" "$@"
}
