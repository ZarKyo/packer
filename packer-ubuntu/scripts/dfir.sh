#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# dfir-tools is already cloned to ~/src/bin/dfir-tools by sift.sh.
# setup-dfir.sh skips the SIFT step (guarded by ~/.config/.sift)
# and adds REMnux as addon on top of SIFT.
cd ~/src/bin/dfir-tools/ || exit 1
chmod +x dfir/*.sh
./dfir/setup-dfir.sh
