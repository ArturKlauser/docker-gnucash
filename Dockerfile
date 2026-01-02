# Define build arguments.
# These args MUST be set on the "docker build" command line.
# Example: docker build --build-arg BASEIMAGE_VERSION=ubuntu-24.04-v4 --build-arg GNUCASH_VERSION=5.13 .
ARG BASEIMAGE_VERSION=undefined
ARG GNUCASH_VERSION=undefined

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
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install GnuCash.
# We explicitly install the version matching the argument to ensure consistency.
# We also install:
# - gnucash-docs: Documentation (if available).
# - libfinance-quote-perl: Finance::Quote support.
# - fonts-dejavu: Fonts for the GUI.
# - adwaita-icon-theme: Icon theme.
# - yelp: Gnome help page browser.
#         Note that it doesn't register itself properly, so we provide a
#         defaults config file separately in rootfs/etc/xdg/mimeapps.list
#         that makes sure GnuCash can start it for displaying its help pages.

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common && \
    add-apt-repository -y ppa:gnucash/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        locales && \
    locale-gen en_US.UTF-8 && \
    # Enable installation of GnuCash documentation.
    #   - This isn't necessary if we use Yelp, since it depends on the .xml help
    #     files that are installed elsewhere (at /usr/share/help/*/gnucash*). The
    #     files here are .html and .pdf files that are necessary for other help
    #     viewers, e.g., for a web browser.
    # echo "path-include=/usr/share/doc/gnucash-docs*" > /etc/dpkg/dpkg.cfg.d/z-gnucash-docs && \
    apt-get install -y --no-install-recommends \
        gnucash=1:${GNUCASH_VERSION}* \
        gnucash-docs \
        yelp \
        libfinance-quote-perl \
        fonts-dejavu \
        adwaita-icon-theme && \
    apt-get remove -y software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy the start script.
COPY startapp.sh /startapp.sh

# Copy the rootfs directory.
COPY rootfs/ /

# Set the name of the application.
RUN set-cont-env APP_NAME "GnuCash"

# Install the application icon.
RUN install_app_icon.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/GnuCash_logo.svg/500px-GnuCash_logo.svg.png"

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/data"]

# Expose ports.
# 5800: Secure web interface
# 5900: VNC (We do not expose this by default in documentation, but it's open in the container)
EXPOSE 5800
