# Define build arguments.
ARG BASEIMAGE_VERSION=alpine-3.23
ARG GNUCASH_VERSION=5.13

# Pull base image.
FROM jlesage/baseimage-gui:${BASEIMAGE_VERSION}-v4

# Define working variables.
ARG GNUCASH_VERSION

# Set the name of the application.
ENV APP_NAME="GnuCash"
ENV SECURE_CONNECTION=1
ENV XDG_CONFIG_HOME=/config/xdg/config
ENV XDG_DATA_HOME=/config/xdg/data
ENV XDG_CACHE_HOME=/config/xdg/cache

# Install GnuCash.
# We explicitly install the version matching the argument to ensure consistency.
RUN apk add --no-cache \
        gnucash=~${GNUCASH_VERSION} \
        py3-gnucash \
        py3-gobject3 \
        py3-cairo \
        adwaita-icon-theme \
        ttf-dejavu

# Copy the start script.
COPY startapp.sh /startapp.sh

# Set the name of the application.
RUN set-cont-env APP_NAME "GnuCash"

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/data"]

# Expose ports.
# 5800: Secure web interface
# 5900: VNC (We do not expose this by default in documentation, but it's open in the container)
EXPOSE 5800
