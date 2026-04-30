$ErrorActionPreference = "Stop"

$iso = "C:\Windows\Temp\windows.iso"
if (-not (Test-Path $iso)) {
    Write-Host "VMware Tools ISO not found at $iso, skipping."
    exit 0
}

Write-Host "Mounting VMware Tools ISO"
$mount  = Mount-DiskImage -ImagePath $iso -PassThru
$letter = ($mount | Get-Volume).DriveLetter
$setup  = "${letter}:\setup64.exe"

Write-Host "Running $setup /S /v `"/qn REBOOT=R`""
Start-Process -FilePath $setup -ArgumentList @("/S", "/v", "/qn REBOOT=R") -Wait

Write-Host "Dismounting"
Dismount-DiskImage -ImagePath $iso | Out-Null
Remove-Item $iso -Force -ErrorAction SilentlyContinue
