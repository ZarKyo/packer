# Load defaults
. ../defaults.ps1

$BASE="remnux"
$CONF_NAME="remnux"
$VM_DIR_NAME="REMnux"

New-VirtualMachine $BASE $CONF_NAME $VM_DIR_NAME