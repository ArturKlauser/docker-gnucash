setup_container_daemon() {
  CONTAINER_DAEMON_NAME="$(mktemp -u dockertest-XXXXXXXXXX)"
  export CONTAINER_DAEMON_NAME

  # Make sure there is no existing instance.
  docker kill "${CONTAINER_DAEMON_NAME}" > /dev/null 2>&1 \
    && docker rm "${CONTAINER_DAEMON_NAME}" > /dev/null 2>&1 || true

  # Create a service for testing that runs after the 'app' service in order to
  # notify us that the 'app' has been started. In addition, it exports the
  # environment variables as the app sees them.
  # shellcheck disable=SC2154
  APPREADY_SERVICE="${TESTS_WORKDIR}/service.d/appready"
  mkdir -p "${APPREADY_SERVICE}"
  export CONTAINER_COM_DIR='/appready-com'
  touch "${APPREADY_SERVICE}/app.dep"
  sed -e "s|@CONTAINER_COM_DIR@|${CONTAINER_COM_DIR}|g" \
    "tests/scripts/appready.sh" > "${APPREADY_SERVICE}/run"
  chmod 755 "${APPREADY_SERVICE}/run"
  # The 'appready' service is not started unless the 'default' service
  # (transitively) depends on it, so we have to add that dependence too.
  DEFAULT_SERVICE="${TESTS_WORKDIR}/service.d/default"
  mkdir -p "${DEFAULT_SERVICE}"
  touch "${DEFAULT_SERVICE}/appready.dep"

  # The appready service communicates with the host by putting files in a
  # mounted volume.
  export HOST_COM_DIR="${TESTS_WORKDIR}/appready-com"
  mkdir -p "${HOST_COM_DIR}"

  # Start the container in daemon mode.
  USER_ID="$(id -u)"
  GROUP_ID="$(id -g)"
  # shellcheck disable=SC2154
  run docker run \
    -d \
    --name "${CONTAINER_DAEMON_NAME}" \
    -e USER_ID="${USER_ID}" \
    -e GROUP_ID="${GROUP_ID}" \
    -v "${APPREADY_SERVICE}:/etc/services.d/appready" \
    -v "${DEFAULT_SERVICE}/appready.dep:/etc/services.d/default/appready.dep" \
    -v "${HOST_COM_DIR}:${CONTAINER_COM_DIR}" \
    "${DOCKER_EXTRA_OPTS[@]}" \
    "${DOCKER_IMAGE}" \
    "${DOCKER_CMD[@]}" \
    2> /dev/null
  # shellcheck disable=SC2154
  [[ "${status}" -eq 0 ]] || force_error "docker command failure: ${output}"
}

teardown_container_daemon() {
  [[ -n "${CONTAINER_DAEMON_NAME}" ]]

  echo "Stopping docker container..."
  # We kill instead of stop the container since in the test environment we
  # don't care about a clean container shutdown and prefer speedy test
  # execution.
  docker kill "${CONTAINER_DAEMON_NAME}"

  echo "Removing docker container..."
  docker rm "${CONTAINER_DAEMON_NAME}"

  # Clear the container ID.
  unset CONTAINER_DAEMON_NAME
}

# Execute command in container.
exec_in_container() {
  [[ -n "${CONTAINER_DAEMON_NAME}" ]]
  echo "exec_in_container: $*" >&3
  docker exec "${CONTAINER_DAEMON_NAME}" "$@"
}

getlog_container_daemon() {
  [[ -n "${CONTAINER_DAEMON_NAME}" ]]
  docker logs -t "${CONTAINER_DAEMON_NAME}"
}

wait_for_container_daemon() {
  echo "Waiting for the docker container daemon to be ready..."
  timeout=120
  for countdown in $(eval "echo {${timeout}..0}"); do
    [[ -f ${HOST_COM_DIR}/appready ]] && break
    ((timeout % 10 == 0)) && echo "waiting ${countdown}..."
    sleep 1
  done

  if [[ ${countdown} -ne 0 ]]; then
    echo "Docker container ready."
  else
    echo "Docker container daemon wait timeout."
    echo "====================================================================="
    echo " DOCKER LOGS"
    echo "====================================================================="
    getlog_container_daemon
    echo "====================================================================="
    echo " END DOCKER LOGS"
    echo "====================================================================="
    false
  fi
}

# Get an environment variable from the environment of the running app.
get_app_env_var() {
  local name=$1

  # We must wait for the container to have started to see the app environment.
  wait_for_container_daemon

  echo -n "appenv: "           # Help debugging on error.
  cat "${HOST_COM_DIR}/appenv" # Help debugging on error.
  echo "searching app env for key: ${name}"
  local value
  # shellcheck disable=2312
  value=$(awk -F= -v key="${name}" \
    '$1 == key { print substr($0, length($1)+2) }' \
    "${HOST_COM_DIR}/appenv")
  echo "value: ${value}"
  run echo "${value}"
}

# Execute command in container app environment.
exec_in_container_app_env() {
  wait_for_container_daemon

  # This function is already called with run. We don't want to use nested
  # 'run' to capture output overwriting $lines[@]. So we capture it by hand.
  exec_in_container sh -c ". ${CONTAINER_COM_DIR}/appenv.sh; $*"
}
