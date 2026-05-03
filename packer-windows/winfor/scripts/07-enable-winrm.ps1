Write-Output "Enabling WinRM..."

# Force every network connection to Private (category 1) via the
# INetworkListManager COM interface. WinRM's HTTP listener and firewall rule
# default to Private/Domain only; on first logon Windows often hasn't classified
# the adapter yet so Get-NetConnectionProfile returns "Public" / "Unidentified".
$NetworkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$Connections = $NetworkListManager.GetNetworkConnections()
$Connections | ForEach-Object { $_.GetNetwork().SetCategory(1) }

# Override Group Policy that blocks unencrypted WinRM traffic on Win11 24H2+.
# Without this, the `winrm set ... AllowUnencrypted="true"` call below is
# silently ignored when the policy is set by Microsoft's secured-core defaults.
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" /v AllowUnencrypted /t REG_DWORD /d 1 /f | Out-Null

Enable-PSRemoting -Force
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow
Set-Service winrm -startuptype "auto"
Restart-Service winrm
