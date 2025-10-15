#!/bin/bash
set -oue pipefail

echo "🚀 Starting SwiftOS build: installing packages..."

### -------------------------------
### 1️⃣ RPM-OSTREE packages
### -------------------------------
echo "📦 Installing RPM-based apps..."
rpm-ostree install -y \
    tmux \
    retroarch \
    dolphin-emu \
    pcsx2 \
    rpcs3 \
    steam \
    lutris \
    heroic-games-launcher \
    bottles

### -------------------------------
### 2️⃣ Flatpak packages (Flathub)
### -------------------------------
echo "🌐 Installing Flatpak-only apps..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Cemu and PPSSPP via Flatpak
flatpak install -y flathub info.cemu.Cemu org.ppsspp.PPSSPP || true

### -------------------------------
### 3️⃣ Optional: Enable Podman
### -------------------------------
echo "🔧 Enabling podman.socket..."
systemctl enable podman.socket

### -------------------------------
### 4️⃣ Clean up caches
### -------------------------------
echo "🧹 Cleaning up caches..."
rpm-ostree cleanup -m
flatpak uninstall --unused -y

echo "✅ SwiftOS build: preinstalled apps complete!"
