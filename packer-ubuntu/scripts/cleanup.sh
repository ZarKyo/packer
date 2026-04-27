#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# -e : exit immediately on error
# -u : treat unset variables as errors
# -o pipefail : fail if any command in a pipeline fails
# IFS : safer word splitting
set -euo pipefail
IFS=$'\n\t'

# Delete unneeded files.
rm -f "$HOME"/*.sh

# For apt
export DEBIAN_FRONTEND=noninteractive

# Remove unneeded packages
apt remove -y gnome-initial-setup
apt remove --purge -y byobu transmission-gtk transmission-cli transmission-common transmission-daemon

# Clean
sudo apt -yqq autoremove
sudo apt autoclean
sudo apt clean

if [[ $(df / | grep "/" | awk '{print $4}') -ge $((60 * 1024 * 1024)) ]]; then
	echo "Disk larger than limit - not zeroing disk."
else
	# Minimum free space to leave (5%)
	MIN_FREE_SPACE_PERCENT=5

	# Path to the temporary zero file
	ZERO_FILE="$HOME/zero"

	# Get disk space information for /
	TOTAL_SPACE_KB=$(df / --output=size | tail -n 1)
	AVAILABLE_SPACE_KB=$(df / --output=avail | tail -n 1)
	TOTAL_SPACE_MB=$((TOTAL_SPACE_KB / 1024))
	AVAILABLE_SPACE_MB=$((AVAILABLE_SPACE_KB / 1024))

	# Calculate 95% of available space (in MB)
	ZERO_FILE_SIZE_MB=$((AVAILABLE_SPACE_MB * (100 - MIN_FREE_SPACE_PERCENT) / 100))

	# Check if there's enough space to proceed
	if [ "$ZERO_FILE_SIZE_MB" -le 0 ]; then
		echo "Warning: Not enough available space to write zeros. Skipping zero-fill."
		ZERO_FILE_SIZE_MB=0
	fi

	if [ "$ZERO_FILE_SIZE_MB" -gt 0 ]; then
		echo "Starting to fill 95% of available disk space with zeros (${ZERO_FILE_SIZE_MB} MB)..."

		# Write zeros to the /zero file
		dd if=/dev/zero of="$ZERO_FILE" bs=1M count="$ZERO_FILE_SIZE_MB" conv=fsync status=progress || {
			echo "Warning: Failed to write zero file. Continuing without zero-fill."
		}
	else
		echo "Skipping zero-fill due to insufficient space."
	fi

	sleep 1
	# Sync and remove the zero file if it exists
	sync
	rm -f "$ZERO_FILE"
	sync

	echo "Zero-fill process completed (or skipped)."

fi
