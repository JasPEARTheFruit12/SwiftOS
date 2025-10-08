#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 


# --- Install Emulators & Gaming Tools ---
dnf5 install -y \
    steam \
    lutris \
    retroarch \
    dolphin-emu \
    pcsx2 \
    rpcs3 \
    ryujinx \
    yuzu \
    mame \
    ppsspp \
    snes9x \
    chromium \
    && dnf5 clean all

# --- Xbox Cloud Gaming (via Web App) ---
# We'll create a desktop shortcut that launches it in Chromium
mkdir -p /usr/share/applications
cat << 'EOF' > /usr/share/applications/xbox-cloud-gaming.desktop
[Desktop Entry]
Name=Xbox Cloud Gaming
Comment=Play Xbox Cloud Gaming through Chromium
Exec=chromium --app=https://www.xbox.com/play --start-maximized
Icon=xbox
Terminal=false
Type=Application
Categories=Game;
EOF

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
