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

curl -fsSL https://raw.githubusercontent.com/ZarKyo/utils/refs/heads/main/bin/screen_lock.sh -o screen_lock.sh
curl -fsSL https://raw.githubusercontent.com/ZarKyo/utils/refs/heads/main/bin/vmware-mount-shared.sh -o vmware-mount-shared.sh
chmod +x ./*.sh

git clone https://github.com/ZarKyo/dfir-tools.git
cd dfir-tools/ || exit
chmod +x common/bin/*.sh
chmod +x sift/*.sh

./sift/setup-sift.sh
./common/bin/set-preferences.sh
make dotfiles
