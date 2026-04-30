$ErrorActionPreference = "Stop"

Write-Output "Enabling Microsoft-Windows-Subsystem-Linux"
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null

Write-Output "Enabling VirtualMachinePlatform"
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null

# A reboot is required before WSL2 distros can be installed; the next
# windows-restart provisioner takes care of it.
exit 0
