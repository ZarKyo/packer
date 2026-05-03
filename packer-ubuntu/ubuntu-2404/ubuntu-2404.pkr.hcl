# ---------------------------
# Versions
# ---------------------------

packer {
  required_version = ">= 1.14.0"
  required_plugins {
    vmware = {
        source  = "github.com/hashicorp/vmware"
        version = ">= 1.2.0"
    }
  }
}

# ---------------------------
# Variables
# ---------------------------

variable "vm_name" {
  type    = string
  default = "ubuntu-2404"
}

variable "cpus" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 4096
}

variable "disk_size" {
  type    = number
  default = 20000
}

variable "hostname" {
  type    = string
  default = "ubuntu-2404"
}

variable "network_adapter_type" {
  type    = string
  default = "vmxnet3"
}

variable "shutdown_command" {
  type    = string
  default = null
}

variable "iso_urls_ubuntu" {
  type    = list(string)
  default = []
}

variable "iso_checksum_ubuntu" {
  type    = string
  default = null
}

variable "username" {
  description = "The default username for the OS"
  type        = string
  default     = ""
}

variable "password" {
  description = "The password for the the default user for the OS"
  type        = string
  default     = ""
  sensitive   = true
}

variable "headless" {
  type    = bool
  default = true
}

locals {
  timestamp = formatdate("YYYY-MM-DD-HH:mm", timestamp())

  cloud_config = templatefile("${path.root}/http/user-data", {
    hostname = var.hostname
    username = var.username
    password = bcrypt(var.password)
  })
}

# ---------------------------------
# Source : Builder VMware Desktop
# ---------------------------------

source "vmware-iso" "ubuntu-2404" {
  boot_wait         = "5s"
#  boot_command      = [
#                        "c<wait>",
#                        "linux /casper/vmlinuz --- autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'",
#                        "<enter><wait>",
#                        "initrd /casper/initrd",
#                        "<enter><wait>",
#                        "boot",
#                        "<enter>"
#                    ]
  boot_command = [
              "e<wait>",
              "<down><down><down><end>",
              " autoinstall 'ds=nocloud;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'",
              "<F10>"
  ]

  vm_name       = "${var.vm_name}"
  guest_os_type = "ubuntu-64"
  headless      = "${var.headless}"

  http_content = {
      "/meta-data" = ""
      "/user-data" = local.cloud_config
  }

  iso_checksum = "${var.iso_checksum_ubuntu}"
  iso_urls     = "${var.iso_urls_ubuntu}"

  output_directory = "${var.vm_name}"

  shutdown_command = "echo '${var.password}' | sudo -S shutdown -P now"

  ssh_username           = "${var.username}"
  ssh_password           = "${var.password}"
  ssh_port               = 22
  ssh_timeout            = "60m"
  ssh_handshake_attempts = 100

  disk_size            = "${var.disk_size}"
  memory               = "${var.memory}"
  cpus                 = "${var.cpus}"
  network_adapter_type = "${var.network_adapter_type}"
  cd_label             = "cidata"
  usb                  = "true"

  snapshot_name  = "Installed"

  vmx_data = {
    "annotation"    : "Packer version: ${packer.version}|0D|0AVM creation time: ${formatdate("DD MM YYYY hh:mm ZZZ", timestamp())}|0D|0AUsername: ${var.username}|0D|0APassword: ${var.password}",
    "firmware"      : "efi",
  }
}

# ---------------------------
# Build
# ---------------------------

build {
  name    = "ubuntu-desktop-2404"
  sources = ["source.vmware-iso.ubuntu-2404"]

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = [
        "../scripts/setup.sh",
        "../scripts/disable_ipv6.sh",
        "../scripts/gui.sh",
        "../scripts/faster-boot.sh"
    ]
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} bash '{{ .Path }}'"
    scripts         = [
        "../scripts/set-preferences.sh"
    ]
  }
  
  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = [
        "../scripts/machine-id.sh",
        "../scripts/cleanup.sh"
    ]
  }
}
