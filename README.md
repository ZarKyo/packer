# Packer

[![Super-Linter](https://github.com/ZarKyo/packer/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/super-linter)

> Based on [reuteras/packer](https://github.com/reuteras/packer), adapted and extended.

Automated VMware virtual machine builds using [Packer](https://developer.hashicorp.com/packer). Four VM types are supported, each built from a Ubuntu ISO with unattended installation via cloud-init and configured through provisioning scripts over SSH.

## VMs

| Name | Base OS | Purpose |
| --- | --- | --- |
| `ubuntu-2404` | Ubuntu 24.04 LTS | General-purpose desktop |
| `SIFT` | Ubuntu 24.04 LTS | DFIR forensics workstation |
| `REMnux` | Ubuntu 20.04 LTS | Malware analysis workstation |
| `DFIR` | Ubuntu 24.04 LTS | SIFT + REMnux combined |

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) >= 1.14.0
- VMware Workstation / VMware Fusion
- `vmrun` available in `PATH`
- PowerShell (Windows) for the `.ps1` build scripts

### Windows

Go to [Packer's official website](https://developer.hashicorp.com/packer/install) and download the Packer binary.

Add the following paths to your Path environment variable:

- `Path\to\Packer\binary`
- `C:\Program Files (x86)\VMware\VMware Workstation`.

## Configuration

Edit `defaults.ps1` before the first build to set your local paths:

```powershell
$VM_DIR         = "C:\Users\you\Documents\VMs"
$SHARED_RO_PATH = "C:\Users\you\Documents\VMs\Shared\ro"
$SHARED_RW_PATH = "C:\Users\you\Documents\VMs\Shared\rw"
```

VM-specific settings (ISO URL and checksum, CPU, RAM, disk size, credentials) are in the corresponding `packer-ubuntu/variables-<name>.pkrvars.hcl` file.

## Build

**PowerShell:**

```powershell
cd packer-ubuntu
.\build-ubuntu-2404.ps1
.\build-sift.ps1
.\build-remnux.ps1
.\build-dfir.ps1
```

**Makefile:**

```bash
cd packer-ubuntu
make ubuntu-2404
make sift
make remnux
make dfir
make all        # build all four
make dist-clean # remove ISO cache
```

Each build:

1. Installs Ubuntu unattended from ISO via cloud-init (`http/user-data`)
2. Connects over SSH and runs the provisioning scripts
3. Takes an `Installed` snapshot
4. Moves the VM to `$VM_DIR`, opens it in VMware, and sets up shared folders
5. Takes a final `Secure` snapshot

## Lint

```bash
cd packer-ubuntu
make test   # shellcheck on all provisioning scripts
```
