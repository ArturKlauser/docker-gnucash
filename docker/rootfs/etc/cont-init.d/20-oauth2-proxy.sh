#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Nothing to do if OAUTH2_PROXY is disabled.
if is-bool-val-false "${OAUTH2_PROXY:-0}"; then
  exit 0
fi

echo "Enabling OAuth2 Proxy..."

# Disable WEB_AUTHENTICATION if it is enabled.
if is-bool-val-true "${WEB_AUTHENTICATION:-0}"; then
  echo "WARNING: Disabling WEB_AUTHENTICATION because OAUTH2_PROXY is enabled."
fi

# Config handling
CONFIG_FILE="/config/oauth2-proxy.cfg"
if [ ! -f "${CONFIG_FILE}" ]; then
  echo "Creating empty oauth2-proxy configuration..."
  touch "${CONFIG_FILE}"
fi

# Overwrite Nginx auth config
echo "Overwriting Nginx authentication (WEB_AUTHENTICATION) configuration..."
cp /defaults/default_oauth2_proxy.conf /var/tmp/nginx/auth.conf

# Update webAuthSupport in webdata.json
WEB_DATA_FILE="/tmp/.webdata.json"
if [ -f "${WEB_DATA_FILE}" ]; then
  # Use sed to replace "webAuthSupport": false with "webAuthSupport": true
  sed -i 's/"webAuthSupport": false/"webAuthSupport": true/' "${WEB_DATA_FILE}"
  chmod 444 "${WEB_DATA_FILE}"
fi

# vim:ft=sh:ts=4:sw=4:et:sts=4
