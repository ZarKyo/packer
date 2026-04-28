// variables-sift.pkr.hcl
cpus = 8
memory = 16384
disk_size = 60000

// Defaults for all sift installations
headless  = "true"
username  = "user"
password  = "forensics"

// Ubuntu 24.04 LTS
iso_checksum_ubuntu = "sha256:e907d92eeec9df64163a7e454cbc8d7755e8ddc7ed42f99dbc80c40f1a138433"
iso_urls_ubuntu     = ["https://releases.ubuntu.com/noble/ubuntu-24.04.4-live-server-amd64.iso"]