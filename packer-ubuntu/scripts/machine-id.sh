#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Empty machine-id so systemd generates a unique one on first boot.
# Do not remove /etc/machine-id — systemd expects the file to exist.
rm -f /etc/machine-id && touch /etc/machine-id
rm -f /var/lib/dbus/machine-id
