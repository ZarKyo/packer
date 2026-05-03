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

Write-Output "Downloading winfor-cli.ps1 from $url"
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
Write-Output "Invoking: $out $logArgs"

& $out @arguments
$ok = $?
$rc = $LASTEXITCODE
# $LASTEXITCODE is only set by native executables, not by PS scripts.
# Use $? to also catch failures that leave $LASTEXITCODE null.
if ((-not $ok) -or ($null -ne $rc -and $rc -ne 0)) {
    $code = if ($null -ne $rc) { $rc } else { 1 }
    throw "winfor-cli.ps1 exited with code $code"
}
