#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

Write-Output "Stopping WinRM service"
Stop-Service -Name WinRM -Force -ErrorAction SilentlyContinue

Write-Output "Disabling WinRM service (no auto-start on next boot)"
Set-Service -Name WinRM -StartupType Disabled

Write-Output "Blocking WinRM firewall rules"
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=block | Out-Null
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=no | Out-Null

Write-Output "WinRM disabled."
