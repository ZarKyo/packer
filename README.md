# Packer

[![Super-Linter](https://github.com/ZarKyo/packer/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/super-linter)

> Based on [reuteras/packer](https://github.com/reuteras/packer) and [reuteras/dfirws](https://github.com/reuteras/dfirws/), adapted and extended.

Automated VMware virtual machine builds using [Packer](https://developer.hashicorp.com/packer). Five VM types are supported: four Ubuntu-based VMs (unattended cloud-init, SSH provisioning) and one Windows 11 VM (unattended `Autounattend.xml`, WinRM provisioning).

## VMs

| Name | Base OS | Purpose |
| --- | --- | --- |
| `ubuntu-2404` | Ubuntu 24.04 LTS | General-purpose desktop |
| `SIFT` | Ubuntu 24.04 LTS | DFIR forensics workstation |
| `REMnux` | Ubuntu 20.04 LTS | Malware analysis workstation |
| `DFIR` | Ubuntu 24.04 LTS | SIFT + REMnux combined |
| `WIN-FOR` | Windows 11 | Windows forensics workstation ([digitalsleuth/WIN-FOR](https://github.com/digitalsleuth/WIN-FOR)) |

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) >= 1.14.0
- VMware Workstation / VMware Fusion
- `vmrun` available in `PATH`

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

`defaults.sh`:

```bash
SHARED_RO_PATH="$HOME/VMs/Shared/ro"
SHARED_RW_PATH="$HOME/VMs/Shared/rw"
VM_DIR="$HOME/vmware"
```

VM-specific settings (ISO URL and checksum, CPU, RAM, disk size, credentials) are in the corresponding `packer-ubuntu/variables-<name>.pkrvars.hcl` file.

## Linux VM type

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
make dist-clean # remove packer_cache/
```

Each build:

1. Installs Ubuntu unattended from ISO via cloud-init (`http/user-data`)
2. Connects over SSH and runs the provisioning scripts
3. Takes an `Installed` snapshot
4. Moves the VM to `$VM_DIR`, opens it in VMware, and sets up shared folders
5. Takes a final `Secure` snapshot

### Provisioning scripts

All VM templates share the same `scripts/` directory. Scripts run in this order:

| Script | VMs | Role |
| ------ | --- | ---- |
| `setup.sh` | all | Base packages (git, open-vm-tools, zsh, vim, tmux, wget) + sudo/upgrade config |
| `disable_ipv6.sh` | all | Disable IPv6 |
| `gui.sh` | all | Install GNOME desktop, Firefox, xorg, fonts |
| `faster-boot.sh` | all | Mask `systemd-networkd-wait-online` (VMware workaround) |
| `disable-aptdaily.sh` | SIFT, REMnux, DFIR | Disable apt timers to avoid build conflicts |
| `sift.sh` / `remnux.sh` | per-VM | Install SIFT or REMnux toolset |
| `dfir.sh` | DFIR | Installs REMnux as addon on top of SIFT (`remnux install --mode=addon`) |
| `set-preferences.sh` | ubuntu-2404 | Configure GNOME dock and desktop settings (run as VM user) |
| `machine-id.sh` | all | Clear `/etc/machine-id` so a fresh ID is generated on first boot |
| `cleanup.sh` | all | Remove temp files, apt clean/autoremove, optional disk zero-fill |

`cleanup.sh` skips the zero-fill step if more than 60 GB of disk space is free.

---

## Windows VM type

Windows 11 forensics workstation based on [digitalsleuth/WIN-FOR](https://github.com/digitalsleuth/WIN-FOR). Built from `packer-windows/`.

### ISO

The build requires a Windows 11 x64 ISO. Two options:

**Option 1 — fetch automatically (default)**

`build-winfor.ps1` fetches the Windows 11 Enterprise evaluation ISO (90-day trial, no license needed) from the Microsoft Evaluation Center at runtime. The ISO is cached in `packer-windows/iso/` and reused on subsequent builds.

```powershell
cd packer-windows
.\build-winfor.ps1
```

Set `windows_image_name` in `variables-winfor.pkrvars.hcl` to `"Windows 11 Enterprise Evaluation"` when using this ISO.

**Option 2 — local ISO**

Pass any local Windows 11 ISO (e.g. Pro, downloaded via Media Creation Tool) with `-IsoPath`. The SHA256 checksum is computed automatically.

```powershell
.\build-winfor.ps1 -IsoPath "D:\ISOs\Win11_24H2_x64.iso"
```

Set `windows_image_name` to match the edition embedded in your ISO (must match an `/IMAGE/NAME` inside `install.wim`):

```hcl
# Common values:
windows_image_name = "Windows 11 Pro"
windows_image_name = "Windows 11 Enterprise Evaluation"
windows_image_name = "Windows 11 Enterprise"
```

### Configuration

Edit `variables-winfor.pkrvars.hcl` before building:

| Variable | Default | Description |
| --- | --- | --- |
| `cpus` | `4` | vCPUs |
| `memory` | `8192` | RAM (MB) |
| `disk_size` | `102400` | Disk (MB = 100 GB) |
| `headless` | `true` | Run without a display window |
| `username` | `forensics` | Local admin account name |
| `password` | `forensics` | Local admin password |
| `winfor_mode` | `dedicated` | WIN-FOR install mode: `addon`, `dedicated`, or `custom` |
| `include_wsl` | `true` | Install SIFT and REMnux inside WSL2 |
| `windows_image_name` | `Windows 11` | Edition to install (must match `install.wim`) |
| `xways_user` / `xways_pass` | `""` | Optional X-Ways portal credentials |

### Build steps

1. Boots from ISO via UEFI, installs Windows unattended (`Autounattend.xml`)
2. Runs Windows Updates (via floppy script, before Packer connects); reboots as needed
3. Enables WinRM at the end of the WU loop, then Packer connects
4. Runs the provisioner scripts over WinRM
5. Takes an `Installed` snapshot
6. Moves the VM to `$VM_DIR`, opens it in VMware, and sets up shared folders
7. Takes a final `Secure` snapshot

### Provisioning scripts

Scripts are split into two phases: floppy scripts run before Packer connects (invoked from `Autounattend.xml`), provisioner scripts run over WinRM after Windows Updates complete.

**Floppy scripts** — shipped as `floppy_files`, called from `FirstLogonCommands`:

| Script | Role |
| --- | --- |
| `00-fixnetwork.ps1` | Force network profile → Private (needed before WinRM setup) |
| `01-enable-winrm.ps1` | Full WinRM setup (listener, firewall, auth); called by `03-win-updates.ps1` at exit |
| `02-enable-rdp.ps1` | Enable RDP (port 3389) |
| `03-win-updates.ps1` | Windows Updates loop — polls, downloads, installs, reboots; enables WinRM when done |

**Packer provisioner scripts** — run over WinRM after WU completes:

| Script | Step | Role |
| --- | --- | --- |
| `00-fixnetwork.ps1` | 1 | Re-force network profile → Private after WU reboots |
| `04-vmware-tools.ps1` | 1 | Install VMware Tools from the uploaded ISO |
| `05-disable-defender.ps1` | 2 | Re-apply Defender GP keys (disable for build) |
| `06-set-powerplan.ps1` | 2 | Set High Performance power plan |
| `07-disable-screensaver.ps1` | 2 | Disable screensaver and display timeout |
| `08-enable-wsl.ps1` | 3 | Enable WSL2 and Virtual Machine Platform features |
| `09-install-dotnet.ps1` | 3 | Install .NET 8 Desktop Runtime (required by WIN-FOR GUI) |
| `10-install-winfor.ps1` | 4 | Download and run `winfor-cli.ps1` (SaltStack + tools + WSL distros) |
| `99-cleanup.ps1` | 5 | Remove temp files, restore UAC, disable WinRM on next boot |

---

## Export

`export-ova.ps1` exports a built VM to OVA format using `ovftool`. The VM must be powered off first.

```powershell
.\export-ova.ps1 -VM SIFT
.\export-ova.ps1 -VM REMnux
.\export-ova.ps1 -VM ubuntu-2404
.\export-ova.ps1 -VM SIFT -OutputDir D:\exports
```

Uses `--diskMode=thin` so the OVA only contains written data.

---

## Lint

```bash
cd packer-ubuntu
make test   # shellcheck on all provisioning scripts
```
