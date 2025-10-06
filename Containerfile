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
COPY swiftos-default.png /usr/share/backgrounds/default.jxl

# Set system default for GNOME
RUN mkdir -p /etc/dconf/db/local.d && \
    printf '%s\n' "[org/gnome/desktop/background]" \
    "picture-uri='file:///usr/share/backgrounds/default.jxl'" \
    "picture-options='zoom'" > /etc/dconf/db/local.d/00-swiftos && \
    dconf update
# --------------------------------------------------
# SwiftOS Custom Login Sound Setup (final fixed)
# --------------------------------------------------

# 1. Copy the login sound file into the image
COPY files/sounds/swiftos-login.ogg /usr/share/sounds/swiftos-login.ogg

# 2. Create the playback script in /usr/local/bin (safe for immutable layers)
RUN install -d -m 0755 /usr/local/bin || true
RUN tee /usr/local/bin/swiftos-play-login-sound.sh > /dev/null <<'EOF'
#!/bin/sh
# Play SwiftOS login sound at session start

# Avoid replaying if already played this session
LOCKFILE="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/swiftos-login-played"
[ -e "$LOCKFILE" ] && exit 0

# Wait a bit for audio to initialize
for i in 1 2 3 4 5; do
  if command -v paplay >/dev/null 2>&1; then
    paplay /usr/share/sounds/swiftos-login.ogg && touch "$LOCKFILE" && exit 0
  elif command -v canberra-gtk-play >/dev/null 2>&1; then
    canberra-gtk-play -f /usr/share/sounds/swiftos-login.ogg && touch "$LOCKFILE" && exit 0
  fi
  sleep 1
done

exit 1
EOF
RUN chmod +x /usr/local/bin/swiftos-play-login-sound.sh

# 3. Create a systemd user service to trigger playback at login
RUN install -d -m 0755 /etc/systemd/user || true
RUN tee /etc/systemd/user/swiftos-login-sound.service > /dev/null <<'EOF'
[Unit]
Description=Play SwiftOS login sound

[Service]
Type=oneshot
ExecStart=/usr/local/bin/swiftos-play-login-sound.sh

[Install]
WantedBy=default.target
EOF

# 4. Enable the service globally for all users
RUN systemctl --global enable swiftos-login-sound.service || true


