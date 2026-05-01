$ErrorActionPreference = "Stop"

# Try to find the High Performance GUID dynamically â€” works across all Windows editions
# even if the scheme was renamed or the locale is not English.
$highPerfGuid = powercfg -l | ForEach-Object {
    if ($_ -match 'High performance') { ($_ -split '\s+')[3] }
} | Select-Object -First 1

# Fall back to the well-known Microsoft GUID if dynamic lookup returns nothing.
if (-not $highPerfGuid) {
    $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
}

Write-Output "Activating High Performance power plan ($highPerfGuid)"
powercfg /setactive $highPerfGuid

Write-Output "Disabling hibernate"
powercfg /hibernate off

exit 0
