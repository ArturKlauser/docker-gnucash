#!/bin/sh

# Remove the minimize button from all windows.
# Minimized windows are not retrievable in this environment.
sed -i '/<titleLayout>/s/I//g' /var/run/openbox/rc.xml
