#!/usr/bin/bash
#
# Bash equivalent of defaults.ps1 — source this file from shared.sh scripts.
# Edit the three path variables below for your environment.

SHARED_RO_NAME="ro"
SHARED_RO_PATH="$HOME/VMs/Shared/ro"

SHARED_RW_NAME="rw"
SHARED_RW_PATH="$HOME/VMs/Shared/rw"

VM_DIR="$HOME/vmware"

export PACKER_CACHE_DIR="../packer_cache"

# vmrun location — adjust if not in PATH
VMRUN="${VMRUN:-vmrun}"

# --- No need to edit below --- #

_vmx() { echo "$VM_DIR/$1/$1.vmx"; }

start_vm() {
    local vm="$1"
    $VMRUN start "$(_vmx "$vm")" nogui
    sleep 2
    $VMRUN getGuestIPAddress "$(_vmx "$vm")"
    sleep 2
}

stop_vm() {
    local vm="$1"
    $VMRUN stop "$(_vmx "$vm")"
    sleep 2
    $VMRUN deleteSnapshot "$(_vmx "$vm")" Installed
    sleep 2
    $VMRUN snapshot "$(_vmx "$vm")" Secure
    sleep 2
}

enable_shared_folder() {
    local vm="$1"
    $VMRUN enableSharedFolders "$(_vmx "$vm")"
    sleep 2
}

add_shared_folder() {
    local vm="$1" name="$2" path="$3" state="$4"
    $VMRUN addSharedFolder "$(_vmx "$vm")" "$name" "$path"
    sleep 2
    $VMRUN setSharedFolderState "$(_vmx "$vm")" "$name" "$path" "$state"
    sleep 2
}
