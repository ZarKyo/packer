$ErrorActionPreference = "SilentlyContinue"

Write-Output "Cleaning temp directories"
Remove-Item -Recurse -Force "C:\Windows\Temp\*"
Remove-Item -Recurse -Force "$env:TEMP\*"
Remove-Item -Force "C:\winfor-cli.ps1"

Write-Output "Re-enabling UAC"
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f | Out-Null

Write-Output "Disabling AutoLogon residue (LogonCount expires after 5 logons but be safe)"
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon  /f | Out-Null
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f | Out-Null

# Trim event logs so the snapshot ships small
Get-WinEvent -ListLog * -ErrorAction SilentlyContinue |
    Where-Object { $_.RecordCount -gt 0 } |
    ForEach-Object { wevtutil.exe cl $_.LogName 2>$null }

exit 0
