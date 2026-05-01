// ---------------------------
// Versions
// ---------------------------

packer {
  required_version = ">= 1.14.0"
  required_plugins {
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = ">= 1.2.0"
    }
  }
}

// ---------------------------
// Variables
// ---------------------------

variable "vm_name" {
  type    = string
  default = "WIN-FOR"
}

variable "cpus" {
  type    = number
  default = 4
}

variable "memory" {
  type    = number
  default = 8192
}

variable "disk_size" {
  type    = number
  default = 102400
}

variable "hostname" {
  type    = string
  default = "winfor"
}

variable "network_adapter_type" {
  type    = string
  default = "vmxnet3"
}

variable "iso_urls_windows" {
  type    = list(string)
  default = []
}

variable "iso_checksum_windows" {
  type    = string
  default = null
}

variable "windows_image_name" {
  description = "Edition to install — must match the /IMAGE/NAME inside install.wim of the ISO"
  type        = string
  default     = "Windows 11 Pro"
}

variable "username" {
  type    = string
  default = "forensics"
}

variable "password" {
  type      = string
  default   = "forensics"
  sensitive = true
}

variable "xways_user" {
  description = "Optional X-Ways portal username (leave empty if you do not have an X-Ways license)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "xways_pass" {
  description = "Optional X-Ways portal password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "winfor_mode" {
  description = "WIN-FOR install mode: addon | dedicated | custom"
  type        = string
  default     = "dedicated"
}

variable "include_wsl" {
  description = "Install SIFT and REMnux inside WSL2"
  type        = bool
  default     = false
}

variable "headless" {
  type    = bool
  default = false
}

// ---------------------------------
// Source : VMware Desktop (vmware-iso)
// ---------------------------------

source "vmware-iso" "winfor" {
  vm_name       = var.vm_name
  guest_os_type = "windows11-64"
  headless      = var.headless
  firmware      = "efi"
  version       = 21

  // Hammer <enter> to clear the "Press any key to boot from CD or DVD" prompt.
  // boot_wait = "-1s" disables the initial wait and starts sending keys immediately.
  boot_command = [
    "<enter><wait><enter><wait><enter><wait><enter><wait><enter><wait>",
    "<enter><wait><enter><wait><enter><wait><enter><wait90><enter><wait>",
    "<enter><wait3><enter><wait><enter>"
  ]
  boot_wait    = "-1s"

  iso_urls     = var.iso_urls_windows
  iso_checksum = var.iso_checksum_windows

  // Autounattend.xml is rendered from a template and shipped as a virtual floppy.
  // Windows Setup auto-discovers Autounattend.xml on attached floppy/CD volumes.
  floppy_content = {
    "Autounattend.xml" = templatefile("${path.root}/answer/Autounattend.xml", {
      username   = var.username
      password   = var.password
      hostname   = var.hostname
      image_name = var.windows_image_name
    })
  }

  output_directory = var.vm_name

  // Communicator: WinRM (Autounattend opens it via FirstLogonCommands)
  communicator   = "winrm"
  winrm_username = var.username
  winrm_password = var.password
  winrm_timeout  = "4h"
  winrm_insecure = true
  winrm_use_ssl  = false

  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer shutdown\""
  shutdown_timeout = "30m"

  disk_size            = var.disk_size
  disk_adapter_type    = "lsisas1068"
  memory               = var.memory
  cpus                 = var.cpus
  network_adapter_type = var.network_adapter_type
  usb                  = true

  // VMware Tools ISO is uploaded by Packer and mounted later by 01-vmware-tools.ps1
  tools_upload_flavor = "windows"
  tools_upload_path   = "C:\\Windows\\Temp\\windows.iso"

  // VNC for headless debug (Packer auto-picks a port in this range)
  vnc_port_min = 5900
  vnc_port_max = 5980

  snapshot_name = "Installed"

  vmx_data = {
    "annotation" = "WIN-FOR (digitalsleuth) | Packer ${packer.version} | Built ${formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())} | User: ${var.username}"
  }
}

// ---------------------------
// Build
// ---------------------------

build {
  sources = ["source.vmware-iso.winfor"]

  // Step 1 — force network profile to Private (WinRM fails on Public), then install VMware Tools.
  provisioner "powershell" {
    scripts = [
      "${path.root}/scripts/00-fixnetwork.ps1",
      "${path.root}/scripts/01-vmware-tools.ps1",
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  // Step 2 — neutralize Defender, pin power plan, and suppress screensaver/timeouts
  // before any long-running download / install kicks off.
  provisioner "powershell" {
    scripts = [
      "${path.root}/scripts/02-disable-defender.ps1",
      "${path.root}/scripts/03-set-powerplan.ps1",
      "${path.root}/scripts/03b-disable-screensaver.ps1",
    ]
  }

  // Step 3 — pre-enable WSL features and install .NET 8 Desktop Runtime
  // (WIN-FOR's GUI customizer requires .NET 8; the CLI does not, but we install
  // it so the GUI is usable post-build for re-running selections.)
  provisioner "powershell" {
    scripts = [
      "${path.root}/scripts/04-enable-wsl.ps1",
      "${path.root}/scripts/05-install-dotnet.ps1",
    ]
  }

  // Reboot so Defender policy and WSL features are fully active before the install.
  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  // Step 4 — run winfor-cli.ps1 (the long one: SaltStack + tools + WSL distros)
  provisioner "powershell" {
    environment_vars = [
      "WINFOR_USER=${var.username}",
      "WINFOR_MODE=${var.winfor_mode}",
      "WINFOR_INCLUDE_WSL=${var.include_wsl}",
      "WINFOR_XUSER=${var.xways_user}",
      "WINFOR_XPASS=${var.xways_pass}",
    ]
    scripts           = ["${path.root}/scripts/06-install-winfor.ps1"]
    elevated_user     = var.username
    elevated_password = var.password
    timeout           = "6h"
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  // Step 5 — cleanup temp files, restore UAC
  provisioner "powershell" {
    scripts = ["${path.root}/scripts/99-cleanup.ps1"]
  }
}
