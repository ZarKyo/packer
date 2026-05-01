# Load defaults
. ../defaults.ps1

# Selects the packer variables file: variables-$BASE.pkrvars.hcl
# (ISO URL/checksum, CPU/RAM/disk, credentials)
$BASE="dfir"

# Packer config directory and template file to build: $CONF_NAME/$CONF_NAME.pkr.hcl
# The DFIR template installs SIFT first, then adds REMnux as an addon
$CONF_NAME="dfir"

# Output folder name used by VMware and when moving the VM to $VM_DIR
$VM_DIR_NAME="DFIR"

New-VirtualMachine $BASE $CONF_NAME $VM_DIR_NAME
