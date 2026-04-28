# Load defaults
. ../defaults.ps1

$BASE="sift"
$CONF_NAME="dfir"
$VM_DIR_NAME="DFIR"

New-VirtualMachine $BASE $CONF_NAME $VM_DIR_NAME
