#!/bin/sh

# Override the openbox configuration for multi-window application:
#   * Adds window decor so windows can be moved and resized.
#   * Doesn't start all windows maximized.
sed -i '/Main window/,/<\/application>/ {
    s/\(\s*\)<decor>.*/\1<decor>yes<\/decor>/
    s/\(\s*\)<maximized>.*/\1<maximized>false<\/maximized>/
}' /var/run/openbox/rc.xml > /data/rc.xml.new
