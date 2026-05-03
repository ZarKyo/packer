// variables-winfor.pkrvars.hcl
cpus      = 4
memory    = 8192
disk_size = 102400  // 100 GB

headless = false
username = "forensics"
password = "forensics"

winfor_mode = "dedicated"
include_wsl = true

// X-Ways portal credentials — leave empty if you do not have a license.
xways_user = ""
xways_pass = ""

// Must match an /IMAGE/NAME inside the install.wim of your ISO. Common values:
//   "Windows 11 Pro", "Windows 11 Pro for Workstations", "Windows 11 Enterprise"
windows_image_name = "Windows 11 Enterprise"

// Microsoft does not publish stable direct ISO URLs. Either:
//   1. Download the Win11 x64 English ISO from microsoft.com and host it
//      locally (file:///C:/.../Win11_24H2_English_x64.iso), or
//   2. Fetch it via the Media Creation Tool and reference the local path.
iso_checksum_windows = "sha256:REPLACE_WITH_SHA256_OF_YOUR_ISO"
iso_urls_windows     = [
  "REPLACE_WITH_PATH_OR_URL_TO_WIN11_X64_ISO"
]
