
CONTAINER_DAEMON_NAME="$(mktemp -u dockertest-XXXXXXXXXX)"

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
        TIMEOUT="$(expr "$TIMEOUT" - 1 || true)"
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

# Make sure there is no existing instance.
docker stop "$CONTAINER_DAEMON_NAME" >/dev/null 2>&1 && docker rm "$CONTAINER_DAEMON_NAME" >/dev/null 2>&1 || true

# Create a fake startapp.h
cat << EOF > "${TESTS_WORKDIR}/startapp_daemon.sh"
#!/bin/sh
/usr/bin/gnucash --nofile &
GNUCASH_PID=\$!
READY_FILE='/tmp/appready'
touch "\${READY_FILE}"
echo "Gnucash started!"
wait "\${GNUCASH_PID}"
rm "\${READY_FILE}"
EOF
chmod a+rx "${TESTS_WORKDIR}/startapp_daemon.sh"

# Start the container in daemon mode.
echo "Starting docker container daemon..."
docker_run \
  -d \
  --name "$CONTAINER_DAEMON_NAME" \
  -e USER_ID="$(id -u)" \
  -e GROUP_ID="$(id -g)" \
  -v "${TESTS_WORKDIR}/startapp_daemon.sh:/startapp.sh" \
  "${DOCKER_EXTRA_OPTS[@]}" \
  "${DOCKER_IMAGE}" \
  "${DOCKER_CMD[@]}" \
  2>/dev/null
[ "$status" -eq 0 ] || force_error "docker command failure: $output"

# Wait for the container to be ready.
wait_for_container_daemon
