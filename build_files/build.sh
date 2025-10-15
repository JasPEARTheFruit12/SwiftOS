#!/bin/bash
set -oue pipefail

### Preinstall Software on Bazzite/ublue (rpm-ostree based)
echo "📦 Installing preinstalled software into SwiftOS (rpm-ostree base)..."

# === EMULATORS & GAMING UTILITIES ===
rpm-ostree install -y \
  tmux \
  retroarch \
  dolphin-emu \
  pcsx2 \
  ppsspp-qt \
  snes9x \
  desmume \
  yuzu \
  cemu \
  ryujinx \
  steam \
  lutris \
  mangohud \
  goverlay \
  gamemode \
  wine \
  winetricks \
  protonup-qt

# === Microsoft Edge (for Xbox Cloud Gaming) ===
rpm-ostree install -y microsoft-edge-stable || true

# === Create Xbox Cloud Gaming Web App Shortcut ===
if command -v microsoft-edge >/dev/null 2>&1; then
  echo "🌐 Creating Xbox Cloud Gaming Web App..."
  mkdir -p /usr/share/applications/
  cat <<EOF > /usr/share/applications/xbox-cloud-gaming.desktop
[Desktop Entry]
Name=Xbox Cloud Gaming
Exec=microsoft-edge --app=https://www.xbox.com/play
Icon=xbox
Type=Application
Categories=Game;
EOF
fi

# === Enable Podman socket ===
systemctl enable podman.socket

echo "✅ Preinstalled apps and emulators successfully added to SwiftOS!"
