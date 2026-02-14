#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Nothing to do if OAUTH2_PROXY is disabled.
if is-bool-val-false "${OAUTH2_PROXY:-0}"; then
  exit 0
fi

# Verify that secure connection is enabled.
if is-bool-val-false "${SECURE_CONNECTION:-0}"; then
  echo "ERROR: oauth2 proxy requires secure web access to be enabled."
  echo "       Make sure to set SECURE_CONNECTION=1 environment variable."
  exit 1
fi

# Disable WEB_AUTHENTICATION if it is also enabled.
if is-bool-val-true "${WEB_AUTHENTICATION:-0}"; then
  echo "WARNING: Disabling WEB_AUTHENTICATION because OAUTH2_PROXY is enabled."
fi

# Handle local password file.
PASSWORD_FILE="/config/oauth2-proxy-htpasswd"

if [ -z "${WEB_AUTHENTICATION_USERNAME:-}" ] \
  && [ -z "${WEB_AUTHENTICATION_PASSWORD:-}" ]; then
  if [ ! -s "${PASSWORD_FILE}" ]; then
    echo "INFO: no local user configured for oauth2 proxy."
  fi
elif [ -z "${WEB_AUTHENTICATION_USERNAME:-}" ] \
  || [ -z "${WEB_AUTHENTICATION_PASSWORD:-}" ]; then
  echo "ERROR: missing username or password for local oauth2 proxy user."
  echo "       Make sure that both WEB_AUTHENTICATION_USERNAME and "
  echo "       WEB_AUTHENTICATION_PASSWORD environment variables are set."
  exit 1
else
  # Make sure the password db exists and has the right permissions.
  touch "${PASSWORD_FILE}"
  chmod 600 "${PASSWORD_FILE}"

  # Add password to database.
  echo "${WEB_AUTHENTICATION_PASSWORD}" \
    | htpasswd -B -i "${PASSWORD_FILE}" "${WEB_AUTHENTICATION_USERNAME}"
fi

# Handle oauth2-proxy config file.
CONFIG_FILE="/config/oauth2-proxy.cfg"
DEFAULT_CONFIG_FILE="/defaults/default_oauth2-proxy.cfg"

# Return the value corresponding to key, without the quotes.
get_value_unquoted() {
  key="$1"
  sed -n "s/^\s*${key}\s*=\s*"'"\([^"]*\)".*$/\1/p' "${CONFIG_FILE}"
}

# Set the value corresponding to key, adding quotes around value.
set_value_quoted() {
  key="$1"
  value="$2"
  sed -i "s/\(^\s*${key}\s*=\).*/\1 \"${value}\"/" "${CONFIG_FILE}"
}

# Comment out the line containing key.
comment_out() {
  key="$1"
  sed -i "s/\(^\s*${key}\s*=.*\)/# \1/" "${CONFIG_FILE}"
}

# Comment out the line containing key if the file/directory that it references
# does not exist.
comment_out_if_not_exists() {
  key="$1"
  file=$(get_value_unquoted "${key}")
  if [ ! -e "${file}" ]; then
    comment_out "${key}"
  fi
}

if [ ! -f "${CONFIG_FILE}" ]; then
  echo "Creating default oauth2-proxy configuration..."
  cp "${DEFAULT_CONFIG_FILE}" "${CONFIG_FILE}"

  # Adjust some config settings.
  # Banner with app name and version.
  # shellcheck disable=SC2154
  sed -i "s/\(^\s*banner\s*=\).*/\1 \"${APP_NAME} v${APP_VERSION}\"/" \
    "${CONFIG_FILE}"
  # Comment out lines referencing files that don't exist.
  comment_out_if_not_exists 'custom_sign_in_logo'
  comment_out_if_not_exists 'custom_templates_dir'
  comment_out_if_not_exists 'htpasswd_file'
  # Create a new random cookie_secret.
  random_b64=$(
    python3 -c \
      'import os, base64; \
    print(base64.urlsafe_b64encode(os.urandom(32)).decode())'
  )
  set_value_quoted 'cookie_secret' "${random_b64}"
fi

# Overwrite Nginx auth config.
echo "Replacing Nginx authentication WEB_AUTHENTICATION with OAUTH2-PROXY configuration..."
cp '/defaults/default_oauth2_proxy.conf' '/var/tmp/nginx/auth.conf'

# Update webAuthSupport in webdata.json.
WEB_DATA_FILE="/tmp/.webdata.json"
if [ -f "${WEB_DATA_FILE}" ]; then
  # Set webAuthSupport to true.
  chmod 644 "${WEB_DATA_FILE}"
  sed -i 's/"webAuthSupport": false/"webAuthSupport": true/' "${WEB_DATA_FILE}"
  chmod 444 "${WEB_DATA_FILE}"
fi

# vim:ft=sh:ts=4:sw=4:et:sts=4
