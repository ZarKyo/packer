#Requires -Version 5.1
<#
.SYNOPSIS
    Downloads and caches the Windows 11 Enterprise evaluation ISO from the
    Microsoft Evaluation Center. Resolves the fwlink redirect at runtime so
    builds are not broken when Microsoft rotates the download URL.

.OUTPUTS
    PSCustomObject with:
      Path      — absolute path to the cached ISO file
      Checksum  — "sha256:<hex>" suitable for Packer's iso_checksum variable

.NOTES
    The ISO is stored in packer-windows\iso\ and is excluded from git via
    .gitignore. Subsequent builds reuse the cached file (SHA256 is recomputed
    each time to guarantee integrity).
#>

param(
    # Directory where the ISO is cached. Defaults to packer-windows\iso\.
    [string]$IsoDir = (Join-Path $PSScriptRoot "iso")
)

Set-StrictMode -Version Latest
$ErrorActionPreference  = "Stop"
$InformationPreference  = "Continue"

$EvalUrl = "https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise"

# --- Step 1: find the fwlink download URL on the evaluation center page ------

Write-Information "[fetch-win-iso] Fetching evaluation center page..."
$page = Invoke-WebRequest -Uri $EvalUrl -UseBasicParsing

# The page contains anchor tags like:
#   <a href="https://go.microsoft.com/fwlink/...&culture=en-us..."
#      aria-label="...Download...">...ISO 64-bit Download...</a>
# Strategy: try DOM .Links first (PS 5.1 without -UseBasicParsing would need
# IE; since we used -UseBasicParsing we fall back to regex on raw content).

$fwLink = $null

# Regex approach: match any fwlink URL that is followed (within ~300 chars) by
# the text "ISO 64" — robust against minor HTML structure changes.
$raw = $page.Content
$pattern = '(https://go\.microsoft\.com/fwlink/[^\s"'']+en-us[^\s"'']*)'
foreach ($m in [regex]::Matches($raw, $pattern, 'IgnoreCase')) {
    # Verify "ISO 64" appears near this link (within the surrounding 400 chars)
    $start = [Math]::Max(0, $m.Index - 50)
    $len   = [Math]::Min(400, $raw.Length - $start)
    if ($raw.Substring($start, $len) -match 'ISO\s+64') {
        $fwLink = $m.Value
        break
    }
}

if (-not $fwLink) {
    Write-Error @"
Could not find the Windows 11 ISO download link on:
  $EvalUrl
The Microsoft Evaluation Center page layout may have changed.
As a workaround, download the ISO manually and set iso_urls_windows and
iso_checksum_windows directly in variables-winfor.pkrvars.hcl.
"@
    exit 1
}

# --- Step 2: resolve the fwlink redirect to get the final CDN URL ------------

Write-Information "[fetch-win-iso] Resolving redirect for: $fwLink"
$realUrl = & curl.exe $fwLink -L -I -o NUL -w '%{url_effective}' -s

if (-not $realUrl -or $realUrl -notmatch '^https?://') {
    Write-Error "Failed to resolve redirect. curl exit code: $LASTEXITCODE"
    exit 1
}

Write-Information "[fetch-win-iso] Resolved URL: $realUrl"

# --- Step 3: determine local filename and cache path -------------------------

# Extract the filename from the CDN URL path (e.g. Win11_24H2_EnglishInternational_x64.iso)
$uri      = [System.Uri]$realUrl
$fileName = [System.IO.Path]::GetFileName($uri.LocalPath)
if (-not $fileName -or -not $fileName.ToLower().EndsWith('.iso')) {
    $fileName = "Win11_Enterprise_eval_x64.iso"
}
$isoPath = Join-Path $IsoDir $fileName

# --- Step 4: download if not already cached ----------------------------------

if (Test-Path $isoPath) {
    Write-Information "[fetch-win-iso] Using cached ISO: $isoPath"
} else {
    New-Item -ItemType Directory -Force -Path $IsoDir | Out-Null
    Write-Information "[fetch-win-iso] Downloading $fileName (5-6 GB, this will take a while)..."
    & curl.exe -L -o $isoPath --retry 10 --retry-all-errors --progress-bar $realUrl
    if ($LASTEXITCODE -ne 0) {
        Remove-Item -Path $isoPath -ErrorAction SilentlyContinue
        Write-Error "Download failed (curl exit code $LASTEXITCODE)."
        exit 1
    }
    Write-Information "[fetch-win-iso] Download complete."
}

# --- Step 5: compute SHA256 --------------------------------------------------

Write-Information "[fetch-win-iso] Computing SHA256 (may take a minute)..."
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $isoPath).Hash.ToLower()
Write-Information "[fetch-win-iso] sha256:$hash"

[PSCustomObject]@{
    Path     = $isoPath
    Checksum = "sha256:$hash"
}
