# Define build arguments.
# These args MUST be set on the "docker build" command line.
# Example: docker build --build-arg BASEIMAGE_VERSION=ubuntu-24.04-v4 --build-arg GNUCASH_VERSION=5.13 .
ARG BASEIMAGE_VERSION=ubuntu-24.04-v4
ARG GNUCASH_VERSION=5.13

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
# - gnucash-common: Common files.
# - gnucash-docs: Documentation (if available).
# - libfinance-quote-perl: Finance::Quote support.
# - python3-gnucash: Python bindings.
# - fonts-dejavu: Fonts for the GUI.
# - adwaita-icon-theme: Icon theme.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gnupg \
        ca-certificates \
        wget && \
    mkdir -p /etc/apt/keyrings && \
    wget -qO- https://keyserver.ubuntu.com/pks/lookup?fingerprint=on\&op=get\&search=0x077468D5684973C4BA12B7A7C0DCB0221512D167 | gpg --dearmor -o /etc/apt/keyrings/gnucash.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/gnucash.gpg] https://ppa.launchpadcontent.net/gnucash/ppa/ubuntu noble main" > /etc/apt/sources.list.d/gnucash.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        gnucash=1:${GNUCASH_VERSION}* \
        gnucash-common=1:${GNUCASH_VERSION}* \
        gnucash-docs \
        python3-gnucash=1:${GNUCASH_VERSION}* \
        libfinance-quote-perl \
        fonts-dejavu \
        adwaita-icon-theme && \
    apt-get remove -y gnupg wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy the start script.
COPY startapp.sh /startapp.sh

# Copy the rootfs directory.
COPY rootfs/ /

# Set the name of the application.
RUN set-cont-env APP_NAME "GnuCash"

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/data"]

# Expose ports.
# 5800: Secure web interface
# 5900: VNC (We do not expose this by default in documentation, but it's open in the container)
EXPOSE 5800
