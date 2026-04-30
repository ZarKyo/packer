# Load defaults
. ../defaults.ps1

$BASE        = "winfor"
$CONF_NAME   = "winfor"
$VM_DIR_NAME = "WIN-FOR"

New-VirtualMachine $BASE $CONF_NAME $VM_DIR_NAME
