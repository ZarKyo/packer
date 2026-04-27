// variables-sift.pkr.hcl
cpus = 8
memory = 16384
disk_size = 60000

// Defaults for all sift installations
headless  = "true"
username  = "user"
password  = "forensics"

// Ubuntu 24.04 LTS
iso_checksum_ubuntu = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
iso_urls_ubuntu     = ["https://releases.ubuntu.com/noble/ubuntu-24.04.3-live-server-amd64.iso"]