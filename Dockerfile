# Define build arguments.
# These args MUST be set on the "docker build" command line.
# Example: docker build --build-arg BASEIMAGE_VERSION=alpine-3.23-v4 --build-arg GNUCASH_VERSION=5.13 .
ARG BASEIMAGE_VERSION
ARG GNUCASH_VERSION

# Pull base image.
FROM jlesage/baseimage-gui:${BASEIMAGE_VERSION}

# Define working variables.
# ARGs declared before FROM must be re-declared after FROM to be available in the build stage.
ARG BASEIMAGE_VERSION
ARG GNUCASH_VERSION

# Set the name of the application.
ENV APP_NAME="GnuCash"
ENV SECURE_CONNECTION=1
ENV XDG_CONFIG_HOME=/config/xdg/config
ENV XDG_DATA_HOME=/config/xdg/data
ENV XDG_CACHE_HOME=/config/xdg/cache

# Install GnuCash.
# We explicitly install the version matching the argument to ensure consistency.
# We also install:
# - gnucash-doc: Documentation.
# - gnucash-lang: Localization files.
# - perl-finance-quote: For online stock quotes (requires edge/testing repo).
RUN apk add --no-cache \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        gnucash=~${GNUCASH_VERSION} \
        gnucash-doc=~${GNUCASH_VERSION} \
        gnucash-lang=~${GNUCASH_VERSION} \
        perl-finance-quote \
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
