# Define build arguments.
# These args MUST be set on the "docker build" command line.
# Example:
#   docker buildx build \
#     --build-arg BASEIMAGE_VERSION=ubuntu-24.04-v4.10.7 \
#     --build-arg GNUCASH_VERSION=5.14 .
ARG BASEIMAGE_VERSION=undefined
ARG GNUCASH_VERSION=undefined
# The following args can optionally be overridden on the command line.
ARG WITH_DOCS=true
ARG WITH_FINANCE_QUOTE=true
ARG USE_GNUCASH_PPA=true
ARG LABEL_VERSION=unknown
ARG ICONS_IMAGE=icons-result

# Pull base image for icon generator script.
FROM jlesage/baseimage-gui:${BASEIMAGE_VERSION} AS icons-source
RUN cp "$(which install_app_icon.sh)" /install_app_icon.sh

# Generate icons.
FROM alpine:3.21 AS icons-build
COPY --from=icons-source /install_app_icon.sh /usr/local/bin/install_app_icon.sh
# hadolint ignore=DL3018 # Pin versions in apk add
RUN --mount=type=cache,target=/var/cache/apk <<EO_RUN
  set -ex
  chmod +x /usr/local/bin/install_app_icon.sh
  rm -rf /etc/apk/cache
  ln -sf /var/cache/apk /etc/apk/cache
  apk add --update curl imagemagick sed
  mkdir -p /opt/noVNC/app/images/icons
  # Create a dummy index.html as the script expects to find the markers to
  # inject content.
  echo "<!-- BEGIN Favicons -->" > /opt/noVNC/index.html
  echo "<!-- END Favicons -->" >> /opt/noVNC/index.html
  install_app_icon.sh --no-tools-install \
    "https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/GnuCash_logo.svg/500px-GnuCash_logo.svg.png"
  # Extract the generated HTML content, excluding the markers.
  grep -E -v '<!-- (BEGIN|END) Favicons -->' /opt/noVNC/index.html \
    > /opt/noVNC/app/images/icons/favicons_inner.html
EO_RUN

# Export icons into an otherwise empty image.
FROM scratch AS icons-result
COPY --from=icons-build /opt/noVNC/app/images/icons /icons

# Use a separate stage for the icons source to support variable expansion. For
# multi-platform builds, this stage also copies the icons from the single
# platform they were built on (BUILDPLATFORM) to whatever the target platform is
# for the main-image-build below.
ARG BUILDPLATFORM
FROM --platform=$BUILDPLATFORM ${ICONS_IMAGE} AS icons-provider

# Build main image.
FROM jlesage/baseimage-gui:${BASEIMAGE_VERSION} AS main-image-build

# Define working variables.
# ARGs declared before FROM must be re-declared after FROM to be available in
# the build stage.
ARG BASEIMAGE_VERSION
ARG GNUCASH_VERSION
ARG WITH_DOCS
ARG WITH_FINANCE_QUOTE
ARG USE_GNUCASH_PPA
ARG LABEL_VERSION
ARG USE_OAUTH2_PROXY=false
ARG OAUTH2_PROXY_VERSION=v7.14.2
ARG TARGETARCH

# Set the name of the application.
ENV APP_NAME="GnuCash" \
    APP_VERSION=${GNUCASH_VERSION} \
    DOCKER_IMAGE_VERSION=${LABEL_VERSION} \
    KEEP_APP_RUNNING=1 \
    SECURE_CONNECTION=1 \
    # Disable external VNC access.
    VNC_LISTENING_PORT=-1 \
    # CONTAINER_DEBUG=1 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

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

# hadolint ignore=DL3008 # Pin versions in apt-get install
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    <<EO_RUN
  set -ex
  # Delete the docker-clean configuration to ensure .deb files are persisted in
  # the cache.
  rm -f /etc/apt/apt.conf.d/docker-clean
  apt-get update
  apt-get install -y --no-install-recommends software-properties-common
  if [ "${USE_GNUCASH_PPA}" = "true" ]; then
    # Use Gnucash from its PPA repo.
    add-apt-repository -y ppa:gnucash/ppa
  else
    # Use Gnucash from Ubuntu 25.10 (questing) repo.
    # This increases the image size by ~90 MB vs. the PPA version.
    add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ questing main restricted universe multiverse"
  fi
  apt-get install -y --no-install-recommends locales
  locale-gen en_US.UTF-8
  # Enable installation of GnuCash documentation.
  #   - This isn't necessary if we use Yelp, since it depends on the .xml
  #     help files that are installed elsewhere
  #     (at /usr/share/help/*/gnucash*). The files here are .html and .pdf
  #     files that are necessary for other help viewers, e.g., for a web
  #     browser.
  # echo "path-include=/usr/share/doc/gnucash-docs*" \
  #   > /etc/dpkg/dpkg.cfg.d/z-gnucash-docs
  PACKAGES="gnucash=1:${GNUCASH_VERSION}* fonts-dejavu adwaita-icon-theme"
  if [ "${WITH_FINANCE_QUOTE}" = "true" ]; then
    PACKAGES="${PACKAGES} libfinance-quote-perl"
  fi
  # shellcheck disable=SC2086 # Ignore word splitting for ${PACKAGES}
  apt-get install -y --no-install-recommends ${PACKAGES}
  if [ "${WITH_DOCS}" = "true" ]; then
    apt-get install -y --no-install-recommends yelp

    # The newest version of gnucash-docs is only available in the newer
    # Ubuntu "resolute" (to be 26.04) repo. Temporarily add it.
    repo='deb http://archive.ubuntu.com/ubuntu/ resolute main universe'
    add-apt-repository -y "${repo}"
    apt-get install -y --no-install-recommends gnucash-docs
    add-apt-repository --remove -y "${repo}"
  fi
  apt-get remove -y software-properties-common
  apt-get autoremove -y
EO_RUN

# Helpers for image debugging.
#RUN <<EORUN
#  set -ex
#  apt-get update
#  apt-get install -y --no-install-recommends less strace xdg-utils
#EORUN

# Install OAuth2 Proxy.
RUN if [ "${USE_OAUTH2_PROXY}" = "true" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    echo "Installing OAuth2 Proxy ${OAUTH2_PROXY_VERSION}..." && \
    case "${TARGETARCH}" in \
        "amd64") ARCH="linux-amd64" ;; \
        "arm64") ARCH="linux-arm64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/oauth2-proxy/oauth2-proxy/releases/download/${OAUTH2_PROXY_VERSION}/oauth2-proxy-${OAUTH2_PROXY_VERSION}.${ARCH}.tar.gz" -o oauth2-proxy.tar.gz && \
    tar -xzf oauth2-proxy.tar.gz && \
    mv oauth2-proxy-${OAUTH2_PROXY_VERSION}.${ARCH}/oauth2-proxy /usr/local/bin/ && \
    rm -rf oauth2-proxy.tar.gz oauth2-proxy-${OAUTH2_PROXY_VERSION}.${ARCH} && \
    chmod +x /usr/local/bin/oauth2-proxy && \
    apt-get purge -y --auto-remove curl && \
    rm -rf /var/lib/apt/lists/*; \
fi

# Copy the rootfs directory.
COPY rootfs/ /

# Install the application icon (part 1).
COPY --from=icons-provider /icons /opt/noVNC/app/images/icons

RUN <<EO_RUN
  set -ex
  # Conditionally install the Yelp configuration.
  if [ "${WITH_DOCS}" = "true" ]; then
    cp -r /opt/with-docs/* /
  fi
  rm -rf /opt/with-docs

  # Install the application icon (part 2).
  # Replace content between BEGIN and END markers.
  favicons_html='/opt/noVNC/app/images/icons/favicons_inner.html'
  sed -i -n \
    -e "/<!-- BEGIN Favicons -->/ {p; r ${favicons_html}" \
    -e ':a; n; /<!-- END Favicons -->/ {p; b}; ba}; p' \
    /opt/noVNC/index.html
  rm "${favicons_html}"
EO_RUN

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/data"]

# Expose ports.
# 5800: Secure web interface
# 5900: VNC (We do not expose this by default in documentation, but it's open in
#       the container)
EXPOSE 5800

# Metadata.
LABEL \
  org.label-schema.name="GnuCash" \
  org.label-schema.description="Docker container for GnuCash" \
  org.label-schema.version="${LABEL_VERSION}" \
  org.label-schema.vcs-url="https://github.com/ArturKlauser/docker-gnucash" \
  org.label-schema.schema-version="1.0" \
  org.opencontainers.image.name="GnuCash" \
  org.opencontainers.image.description="Docker container for GnuCash" \
  org.opencontainers.image.version="${LABEL_VERSION}" \
  org.opencontainers.image.url="https://github.com/ArturKlauser/docker-gnucash" \
  org.opencontainers.image.source="https://github.com/ArturKlauser/docker-gnucash" \
  # Reset labels inherited from the base image that don't make sense.
  org.opencontainers.image.ref.name=""
