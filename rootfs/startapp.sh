#!/bin/sh

# Clean up gnucash/GTK "File Open" panel:
# Make "Home" shortcut point to our data directory.
HOME='/data'
# Suppress the "CWD" shortcut by making it the same as Home.
# shellcheck disable=SC2164
cd "${HOME}"
# Suppress the "Desktop" shortcut by making it the same as Home.
config_file='/config/xdg/config/user-dirs.dirs'
if [ ! -e "${config_file}" ]; then
  # Leave the config file alone if it already exists.
  mkdir -p "$(dirname "${config_file}")"
  # shellcheck disable=SC2016
  echo 'XDG_DESKTOP_DIR="$HOME"' > "${config_file}"
fi

exec /usr/bin/gnucash --nofile
