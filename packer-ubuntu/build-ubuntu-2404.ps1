# Load defaults
. ../defaults.ps1

$BASE="ubuntu-2404"
$CONF_NAME="ubuntu-2404"
$VM_DIR_NAME="ubuntu-2404"

New-VirtualMachine $BASE $CONF_NAME $VM_DIR_NAME
