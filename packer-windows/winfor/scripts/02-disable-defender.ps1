$ErrorActionPreference = "SilentlyContinue"

# Forensics VMs cannot have Defender quarantining SIFT/REMnux tools or malware
# samples. Tamper Protection blocks Set-MpPreference at runtime, so the durable
# fix is the Group Policy registry keys — they are honored after reboot.

Write-Host "Applying Defender Group Policy registry keys"

$gpRoots = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet"
)
foreach ($p in $gpRoots) {
    if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
}

$gp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$rt = "$gp\Real-Time Protection"
$sn = "$gp\Spynet"

Set-ItemProperty $gp -Name "DisableAntiSpyware" -Value 1 -Type DWord -Force
Set-ItemProperty $gp -Name "DisableAntiVirus"   -Value 1 -Type DWord -Force

Set-ItemProperty $rt -Name "DisableRealtimeMonitoring"   -Value 1 -Type DWord -Force
Set-ItemProperty $rt -Name "DisableBehaviorMonitoring"   -Value 1 -Type DWord -Force
Set-ItemProperty $rt -Name "DisableOnAccessProtection"   -Value 1 -Type DWord -Force
Set-ItemProperty $rt -Name "DisableScanOnRealtimeEnable" -Value 1 -Type DWord -Force

Set-ItemProperty $sn -Name "SubmitSamplesConsent" -Value 2 -Type DWord -Force
Set-ItemProperty $sn -Name "SpynetReporting"      -Value 0 -Type DWord -Force

# Best-effort runtime disable (silently no-op under Tamper Protection)
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection     $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning     $true -ErrorAction SilentlyContinue
Set-MpPreference -SubmitSamplesConsent      2     -ErrorAction SilentlyContinue
Set-MpPreference -MAPSReporting             0     -ErrorAction SilentlyContinue

# Belt-and-suspenders for the build phase
Add-MpPreference -ExclusionPath "C:\" -ErrorAction SilentlyContinue

Write-Host "Defender policy applied (full effect after next reboot)."
exit 0
