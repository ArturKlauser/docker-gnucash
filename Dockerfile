# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.20-v4

# Set the name of the application.
ENV APP_NAME="GnuCash"
ENV SECURE_CONNECTION=1
ENV XDG_CONFIG_HOME=/config/xdg/config
ENV XDG_DATA_HOME=/config/xdg/data
ENV XDG_CACHE_HOME=/config/xdg/cache

# Install GnuCash from Alpine Edge.
# We need both main and community repositories from edge for gnucash and its dependencies.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        gnucash \
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
