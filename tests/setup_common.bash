
force_error() {
    echo "# --- ERROR: $@" >&3
    exit 1
}

docker_run() {
    run docker run "$@"
}

[ -n "$DOCKER_IMAGE" ] \
  || force_error 'DOCKER_IMAGE environment variable not defined'

# Make sure the docker image exists.
docker inspect "$DOCKER_IMAGE" > /dev/null \
  || force_error "DOCKER_IMAGE '$DOCKER_IMAGE' does not exist"

# Create workdir to store temporary stuff.
TESTS_WORKDIR="$(mktemp -d)"

