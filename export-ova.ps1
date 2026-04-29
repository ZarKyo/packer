# Export a VMware Workstation VM to OVA format using ovftool.
# Usage:
#   .\export-ova.ps1                    # exports SIFT (default)
#   .\export-ova.ps1 -VM SIFT
#   .\export-ova.ps1 -VM REMnux
#   .\export-ova.ps1 -VM ubuntu-2404
#
# Requires: VMware ovftool in PATH or at the default install location.

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$VM = "SIFT",
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

$VmxPath = "$VM_DIR\$VM\$VM.vmx"
if (-not (Test-Path $VmxPath)) {
    Write-Error "VM not found at: $VmxPath"
    exit 1
}

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
