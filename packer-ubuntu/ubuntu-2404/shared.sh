#!/usr/bin/bash
set -euo pipefail
. "$(dirname "$0")/../../defaults.sh"

VM="ubuntu-2404"

start_vm          "$VM"
enable_shared_folder "$VM"
add_shared_folder "$VM" "$SHARED_RO_NAME" "$SHARED_RO_PATH" "readonly"
add_shared_folder "$VM" "$SHARED_RW_NAME" "$SHARED_RW_PATH" "writable"
stop_vm           "$VM"
