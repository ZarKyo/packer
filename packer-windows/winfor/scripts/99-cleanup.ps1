$ErrorActionPreference = "SilentlyContinue"

Write-Output "Cleaning temp directories"
Remove-Item -Recurse -Force "C:\Windows\Temp\*"
Remove-Item -Recurse -Force "$env:TEMP\*"
Remove-Item -Force "C:\winfor-cli.ps1"

Write-Output "Re-enabling UAC"
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f | Out-Null

Write-Output "Disabling AutoLogon residue (LogonCount expires after 10 logons but be safe)"
$winlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Remove-ItemProperty -Path $winlogon -Name "AutoAdminLogon"  -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $winlogon -Name "DefaultPassword" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $winlogon -Name "AutoLogonCount"  -ErrorAction SilentlyContinue

Write-Output "Disabling widgets"
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0 -Type DWord -Force

Write-Output "Setting taskbar search to icon only"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
    -Name "SearchboxTaskbarMode" -Value 1 -Type DWord -Force

# Trim event logs so the snapshot ships small
Get-WinEvent -ListLog * -ErrorAction SilentlyContinue |
    Where-Object { $_.RecordCount -gt 0 } |
    ForEach-Object { wevtutil.exe cl $_.LogName 2>$null }

# WinRM is left running so Packer can receive this script's exit code and
# execute shutdown_command. Run a:\disable-winrm.ps1 manually after the build
# if you want WinRM disabled on the shipped VM.

exit 0
