# Export a VMware Workstation VM to OVA format using ovftool.
# Usage:
#   .\export-ova.ps1 -VM SIFT
#   .\export-ova.ps1 -VM REMnux
#   .\export-ova.ps1 -VM ubuntu-2404
#   .\export-ova.ps1 -VM MyCustomVM
#   .\export-ova.ps1 -VmxPath "D:\VMs\MyVM\MyVM.vmx"
#   .\export-ova.ps1 -VM SIFT -OutputDir D:\exports
#
# Requires: VMware ovftool in PATH or at the default install location.

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$VM = "",
    [string]$VmxPath = "",
    [string]$OutputDir = "$PSScriptRoot\exports"
)

. $PSScriptRoot\defaults.ps1

# Locate ovftool
$OvfToolPaths = @(
    "ovftool",
    "C:\Program Files (x86)\VMware\VMware Workstation\OVFTool\ovftool.exe",
    "C:\Program Files\VMware\VMware Workstation\OVFTool\ovftool.exe"
)

$OvfTool = $null
foreach ($candidate in $OvfToolPaths) {
    if (Get-Command $candidate -ErrorAction SilentlyContinue) {
        $OvfTool = $candidate
        break
    }
    if (Test-Path $candidate) {
        $OvfTool = $candidate
        break
    }
}

if (-not $OvfTool) {
    Write-Error "ovftool not found. Install VMware OVF Tool or add it to PATH."
    exit 1
}

if (-not $VM -and -not $VmxPath) {
    Write-Error "Specify a VM name (-VM) or a VMX path (-VmxPath)."
    exit 1
}

if (-not $VmxPath) {
    # Try exact match first, then search the VM folder for any .vmx file
    $VmxPath = "$VM_DIR\$VM\$VM.vmx"
    if (-not (Test-Path $VmxPath)) {
        $VmDir = "$VM_DIR\$VM"
        if (-not (Test-Path $VmDir)) {
            Write-Error "VM folder not found: $VmDir"
            exit 1
        }
        $found = Get-ChildItem -Path $VmDir -Filter "*.vmx" -File | Select-Object -First 1
        if (-not $found) {
            Write-Error "No .vmx file found in: $VmDir"
            exit 1
        }
        $VmxPath = $found.FullName
        Write-Output "Using VMX: $VmxPath"
    }
} elseif (-not (Test-Path $VmxPath)) {
    Write-Error "VMX file not found at: $VmxPath"
    exit 1
}

# Derive a display name from the VMX filename for the output OVA
$VM = [System.IO.Path]::GetFileNameWithoutExtension($VmxPath)

# Create output directory if needed
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$OvaPath = "$OutputDir\$VM-$Timestamp.ova"

Write-Output "Exporting $VM -> $OvaPath"
Write-Output "This may take several minutes depending on disk size..."

if ($PSCmdlet.ShouldProcess($OvaPath, "Export OVA")) {
    Write-Output "Running: $OvfTool --acceptAllEulas --noSSLVerify --diskMode=thin `"$VmxPath`" `"$OvaPath`""
    & $OvfTool `
        --acceptAllEulas `
        --noSSLVerify `
        --diskMode=thin `
        "$VmxPath" `
        "$OvaPath"

    if ($LASTEXITCODE -eq 0) {
        $SizeGB = [math]::Round((Get-Item $OvaPath).Length / 1GB, 2)
        Write-Output ""
        Write-Output "Export complete: $OvaPath ($SizeGB GB)"
    } else {
        Write-Error "ovftool exited with code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}
