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

# Install
apt -yqq update
apt -yqq install git open-vm-tools open-vm-tools-desktop screen tmux vim wget whois zsh
apt -yqq dist-upgrade

# Disable 'requiretty' in /etc/sudoers so that sudo can be run non-interactively
# (e.g., from scripts or cron jobs). This line searches for any line containing
# 'requiretty' and comments it out.
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# If the file /etc/update-manager/release-upgrades exists, change the release
# upgrade prompt from 'lts' to 'never', effectively disabling automatic prompts
# for new Ubuntu releases.
if [[ -e /etc/update-manager/release-upgrades ]]; then
    sed -i "s/Prompt=lts/Prompt=never/" /etc/update-manager/release-upgrades
fi

