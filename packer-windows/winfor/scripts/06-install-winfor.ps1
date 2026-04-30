$ErrorActionPreference = "Stop"

$WinforUser = $env:WINFOR_USER
$Mode       = $env:WINFOR_MODE
$IncludeWsl = ($env:WINFOR_INCLUDE_WSL -eq "true")
$XUser      = $env:WINFOR_XUSER
$XPass      = $env:WINFOR_XPASS

if (-not $WinforUser) { throw "WINFOR_USER not set" }
if (-not $Mode)       { $Mode = "dedicated" }

$url = "https://raw.githubusercontent.com/digitalsleuth/WIN-FOR/main/winfor-cli.ps1"
$out = "C:\winfor-cli.ps1"

Write-Host "Downloading winfor-cli.ps1 from $url"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing

Set-ExecutionPolicy Bypass -Scope Process -Force

$arguments = @("-Install", "-User", $WinforUser, "-Mode", $Mode)
if ($IncludeWsl) { $arguments += "-IncludeWsl" }
if ($XUser)      { $arguments += @("-XUser", $XUser) }
if ($XPass)      { $arguments += @("-XPass", $XPass) }

# Mask credentials in the log line
$logArgs = $arguments | ForEach-Object {
    if ($_ -eq $XPass -and $XPass) { "***" } else { $_ }
}
Write-Host "Invoking: $out $logArgs"

& $out @arguments
$rc = $LASTEXITCODE
if ($rc -ne 0) {
    throw "winfor-cli.ps1 exited with code $rc"
}
