#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# -e : exit immediately on error
# -u : treat unset variables as errors
# -o pipefail : fail if any command in a pipeline fails
# IFS : safer word splitting
set -euo pipefail
IFS=$'\n\t'

mkdir -p ~/src/bin/
cd  ~/src/bin/ || exit

# TODO: replace with real URLs before building
curl -fsSL https:// -o screen_lock.sh
curl -fsSL https:// -o vmware-mount-shared.sh
chmod +x *.sh

# TODO: replace with real repo URL before building
git clone https://
cd dfir-tools/ || exit
chmod +x common/bin/*.sh
chmod +x sift/*.sh

./sift/setup-sift.sh
./common/bin/set-preferences.sh
make dotfiles
