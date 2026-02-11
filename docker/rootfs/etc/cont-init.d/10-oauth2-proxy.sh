#!/bin/sh
set -e
set -u

# Nothing to do if OAUTH2_PROXY is disabled.
if [ "${OAUTH2_PROXY:-}" != "true" ]; then
    exit 0
fi

echo "Enabling OAuth2 Proxy..."

# Disable WEB_AUTHENTICATION if it is enabled.
if [ "${WEB_AUTHENTICATION:-}" = "true" ]; then
    echo "WARNING: Disabling WEB_AUTHENTICATION because OAUTH2_PROXY is enabled."
fi

# Config handling
CONFIG_FILE="/config/oauth2-proxy.cfg"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating empty oauth2-proxy configuration..."
    touch "$CONFIG_FILE"
fi

# Overwrite Nginx auth config
echo "Overwriting Nginx authentication configuration..."
cp /defaults/default_oauth2_proxy.conf /var/tmp/nginx/auth.conf
