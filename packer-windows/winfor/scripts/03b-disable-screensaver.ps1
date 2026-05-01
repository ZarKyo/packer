$ErrorActionPreference = "Stop"

# Disable the screensaver via registry. The WIN-FOR install can run for several
# hours and we do not want the screensaver locking the session mid-build.
Write-Output "Disabling screensaver"
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name ScreenSaveActive -Value 0 -Type DWord -Force

# Zero out all sleep / display / disk timeouts so the VM never suspends during the build.
Write-Output "Zeroing out sleep / display / disk timeouts (AC and DC)"
powercfg /change monitor-timeout-ac   0
powercfg /change monitor-timeout-dc   0
powercfg /change disk-timeout-ac      0
powercfg /change disk-timeout-dc      0
powercfg /change standby-timeout-ac   0
powercfg /change standby-timeout-dc   0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0

exit 0
