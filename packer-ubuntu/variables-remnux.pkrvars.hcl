// variables-remnux.pkr.hcl
cpus = 8
memory = 16384
disk_size = 60000

// Defaults for all remnux installations
headless  = "true"
username  = "user"
password  = "remnux"

// Ubuntu 20.04 LTS
iso_checksum_ubuntu = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
iso_urls_ubuntu     = ["https://releases.ubuntu.com/focal/ubuntu-20.04.6-live-server-amd64.iso"]