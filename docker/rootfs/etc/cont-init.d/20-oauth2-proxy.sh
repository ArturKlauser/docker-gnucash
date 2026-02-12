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
echo "Overwriting Nginx authentication configuration..."
cp /defaults/default_oauth2_proxy.conf /var/tmp/nginx/auth.conf

# Enable the service.
if [ -f /etc/services.d/oauth2-proxy/disabled ]; then
    rm /etc/services.d/oauth2-proxy/disabled
fi

# Update webAuthSupport in webdata.json
WEB_DATA_FILE="/tmp/.webdata.json"
if [ -f "${WEB_DATA_FILE}" ]; then
    # Create a temp file.
    TMP_WEB_DATA_FILE=$(mktemp)
    # Use sed to replace "webAuthSupport": false with "webAuthSupport": true
    sed 's/"webAuthSupport": false/"webAuthSupport": true/' "${WEB_DATA_FILE}" > "${TMP_WEB_DATA_FILE}"
    # Move the temp file back to the original location and set permissions.
    cat "${TMP_WEB_DATA_FILE}" > "${WEB_DATA_FILE}"
    rm "${TMP_WEB_DATA_FILE}"
    chmod 444 "${WEB_DATA_FILE}"
fi

# vim:ft=sh:ts=4:sw=4:et:sts=4
