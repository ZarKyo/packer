# Default location for virtual machines
# Change the values below for your environment. You have to create the directories.

# Name and location of readonly folder to mount in VM
$SHARED_RO_NAME = "ro"
$SHARED_RO_PATH = "C:\Users\zarkyo\Documents\VMs\Shared\ro"

# Name and location of writable folder to mount in VM
$SHARED_RW_NAME = "rw"
$SHARED_RW_PATH = "C:\Users\zarkyo\Documents\VMs\Shared\rw"

# Folder to store VMs in after they are created
$VM_DIR = "C:\Users\zarkyo\Documents\VMs"

# Variables are exported for use by dot-sourcing scripts (e.g. shared.ps1)
$null = $SHARED_RO_NAME, $SHARED_RO_PATH, $SHARED_RW_NAME, $SHARED_RW_PATH

# --- No need to edit below --- #

# Defaults for shared cache for Packer.
$env:PACKER_CACHE_DIR = "../packer_cache"

# Functions
function New-VirtualMachine {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $BASE,
        $CONF_NAME,
        $VM_DIR_NAME,
        # Optional extra -var-file paths passed to packer (relative to $CONF_NAME/).
        # Used by Windows builds to inject the auto-fetched ISO path and checksum.
        [string[]]$ExtraVarFiles = @()
    )
    if ($PSCmdlet.ShouldProcess($VM_DIR_NAME, 'New')) {
        if (Test-Path $VM_DIR/$VM_DIR_NAME) {
            Write-Output "Directory for VM exists. Remove it and rerun the script. Exiting."
            Exit
        }

        Set-Location $CONF_NAME

        # Build the list of extra -var-file arguments (flat array for splatting)
        $extraArgs = @()
        foreach ($f in $ExtraVarFiles) { $extraArgs += "-var-file"; $extraArgs += $f }

        packer build -force -var-file ../variables-$BASE.pkrvars.hcl @extraArgs ./$CONF_NAME.pkr.hcl
        Start-Sleep -s 2

        if (-not (Test-Path $VM_DIR/$VM_DIR_NAME)) {
            Move-Item ./$VM_DIR_NAME $VM_DIR
            Start-Sleep -s 2
        } else {
            Write-Output "Directory for VM has been created already during packer run. Exiting."
            Exit
        }

        if (Test-Path ./shared.ps1) {
            ./shared.ps1
        }

        Set-Location ..
        vmware.exe -q -t $VM_DIR/$VM_DIR_NAME/$VM_DIR_NAME.vmx
        Start-Sleep -s 2
    }
}

function Enable-SharedFolder($VM_DIR_NAME) {
    vmrun.exe enableSharedFolders $VM_DIR/$VM_DIR_NAME/$VM_DIR_NAME.vmx
    Start-Sleep -s 2
}

function Add-SharedFolder($VM_DIR_NAME, $SHARE_NAME, $SHARE_PATH, $SHARED_STATE) {
    vmrun.exe addSharedFolder $VM_DIR/$VM_DIR_NAME/$VM_DIR_NAME.vmx $SHARE_NAME $SHARE_PATH
    Start-Sleep -s 2
    vmrun.exe setSharedFolderState $VM_DIR/$VM_DIR_NAME/$VM_DIR_NAME.vmx $SHARE_NAME $SHARE_PATH $SHARED_STATE
    Start-Sleep -s 2
}

function Start-VM {
    [CmdletBinding(SupportsShouldProcess)]
    param($VM_DIR_NAME)
    if ($PSCmdlet.ShouldProcess($VM_DIR_NAME, 'Start')) {
        vmrun.exe start $VM_DIR/$VM_DIR_NAME/$VM_DIR_NAME.vmx nogui
        Start-Sleep -s 2
        # Wait until running
        vmrun.exe getGuestIPAddress $VM_DIR/$VM_DIR_NAME/$VM_DIR_NAME.vmx
        Start-Sleep -s 2
    }
}

function Stop-VM {
    [CmdletBinding(SupportsShouldProcess)]
    param($VM_DIR_NAME)
    if ($PSCmdlet.ShouldProcess($VM_DIR_NAME, 'Stop')) {
        vmrun.exe stop $VM_DIR/$VM_DIR_NAME/$VM_DIR_NAME.vmx
        Start-Sleep -s 2
        vmrun.exe deleteSnapshot $VM_DIR/$VM_DIR_NAME/$VM_DIR_NAME.vmx Installed
        Start-Sleep -s 2
        vmrun.exe snapshot $VM_DIR/$VM_DIR_NAME/$VM_DIR_NAME.vmx Secure
        Start-Sleep -s 2
    }
}
