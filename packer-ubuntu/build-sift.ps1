# Load defaults
. ../defaults.ps1

$BASE="sift"
$CONF_NAME="sift"
$VM_DIR_NAME="SIFT"

New-VirtualMachine $BASE $CONF_NAME $VM_DIR_NAME
