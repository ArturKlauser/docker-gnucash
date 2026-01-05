exec_container_daemon() {
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
    run exec_container_daemon sh -c "[ -f /tmp/appready ]"
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
touch '/tmp/appready'
EOF
  chmod 755 "${NOTIFIER_DIR}/run"
  # The 'appready' service is not started unless the 'default' service
  # (transitively) depends on it, so we have to add that dependence too.
  DEFAULT_DIR="${TESTS_WORKDIR}/service.d/default"
  mkdir -p "${DEFAULT_DIR}"
  touch "${DEFAULT_DIR}/appready.dep"

  # Start the container in daemon mode.
  docker_run \
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
