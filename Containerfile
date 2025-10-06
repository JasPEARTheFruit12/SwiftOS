# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/bazzite:stable

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

# Add default wallpaper and system dconf default for GNOME
COPY swiftos-default.png /usr/share/backgrounds/swiftos-default.png

RUN mkdir -p /etc/dconf/db/local.d && \
    printf '%s\n' "[org/gnome/desktop/background]" \
    "picture-uri='file:///usr/share/backgrounds/swiftos-default.png'" \
    "picture-options='zoom'" > /etc/dconf/db/local.d/00-swiftos && \
    dconf update

# Override Bazzite default wallpaper
COPY files/swiftos-default.png /usr/share/backgrounds/default.jxl

# Set system default for GNOME
RUN mkdir -p /etc/dconf/db/local.d && \
    printf '%s\n' "[org/gnome/desktop/background]" \
    "picture-uri='file:///usr/share/backgrounds/default.jxl'" \
    "picture-options='zoom'" > /etc/dconf/db/local.d/00-swiftos && \
    dconf update

