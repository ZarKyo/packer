$ErrorActionPreference = "Stop"

# WIN-FOR's GUI customizer (WinFOR-Customizer) requires .NET 8 Desktop Runtime.
# winfor-cli.ps1 itself does not, but install it so the GUI can be re-run later.
$url = "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe"
$out = Join-Path $env:TEMP "dotnet8-desktop.exe"

Write-Output "Downloading .NET 8 Desktop Runtime from $url"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing

Write-Output "Installing"
$proc = Start-Process -FilePath $out -ArgumentList @("/install", "/quiet", "/norestart") -Wait -PassThru
Remove-Item $out -Force -ErrorAction SilentlyContinue

# 0 = success, 3010 = success but reboot required
if ($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) {
    throw ".NET 8 installer exited with code $($proc.ExitCode)"
}
exit 0
