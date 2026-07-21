#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# -e : exit immediately on error
# -u : treat unset variables as errors
# -o pipefail : fail if any command in a pipeline fails
# IFS : safer word splitting
set -euo pipefail
IFS=$'\n\t'

# For apt
export DEBIAN_FRONTEND=noninteractive

sudo apt update

# 1. Ubuntu GNOME desktop
sudo apt install -y ubuntu-desktop grub-gfxpayload-lists \
	gnome-session gnome-shell gnome-control-center gnome-terminal gnome-settings-daemon \
	gnome-shell-extension-ubuntu-dock gnome-shell-extension-appindicator \
	nautilus \
	gnome-text-editor \
	gnome-system-monitor \
	gnome-calculator

# 2. Graphics drivers & display utilities
sudo apt install -y \
	xorg \
	xserver-xorg \
	x11-xserver-utils \
	mesa-utils
	
# 3. Network & connection management
sudo apt install -y \
	network-manager \
	network-manager-gnome

# 4. Fonts, themes, and integration
sudo apt install -y \
	fonts-dejavu \
	fonts-liberation \
	xfonts-base

# 5. Basic useful tools
sudo apt install -y \
	file-roller \
	eog \
	evince \
	gnome-disk-utility

# 6. Firefox from Mozilla's APT repo instead of the snap.
# On 24.04 the `firefox` package is a transitional shim that installs the snap,
# and a snap is a loopback squashfs mount that does NOT survive being captured
# into a live ISO. The Mozilla .deb installs into /usr, so it is captured
# normally and works offline on the installed system.
sudo install -d -m 0755 /etc/apt/keyrings
wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg \
	| sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
	| sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
# Pin so the Mozilla build always wins over Ubuntu's transitional (snap) package,
# now and on future upgrades.
printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
	| sudo tee /etc/apt/preferences.d/mozilla > /dev/null
# Drop the snap and the transitional package that ubuntu-desktop pulled in.
sudo snap remove --purge firefox 2>/dev/null || true
sudo apt purge -y firefox 2>/dev/null || true
sudo apt update
sudo apt install -y firefox
