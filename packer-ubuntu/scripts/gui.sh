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
	gnome-disk-utility \
	firefox
