$ErrorActionPreference = "Stop"

# Skip on provisioner retry: if VMware Tools is already installed the ISO has
# already been removed (or the previous run triggered a reboot mid-script).
if (Get-Service -Name "VMTools" -ErrorAction SilentlyContinue) {
    Write-Output "VMware Tools already installed, skipping."
    exit 0
}

$iso = "C:\Windows\Temp\windows.iso"
if (-not (Test-Path $iso)) {
    Write-Output "VMware Tools ISO not found at $iso, skipping."
    exit 0
}

Write-Output "Mounting VMware Tools ISO"
$mount  = Mount-DiskImage -ImagePath $iso -PassThru
$letter = ($mount | Get-Volume).DriveLetter
$setup  = "${letter}:\setup64.exe"

Write-Output "Running $setup /S /v `"/qn REBOOT=R`""
Start-Process -FilePath $setup -ArgumentList @("/S", "/v", "/qn REBOOT=R") -Wait

Write-Output "Dismounting"
Dismount-DiskImage -ImagePath $iso | Out-Null
Remove-Item $iso -Force -ErrorAction SilentlyContinue
