# Packer

[![Super-Linter](https://github.com/ZarKyo/packer/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/super-linter)

> Based on [reuteras/packer](https://github.com/reuteras/packer) and [reuteras/dfirws](https://github.com/reuteras/dfirws/), adapted and extended.

Automated VMware virtual machine builds using [Packer](https://developer.hashicorp.com/packer). Four VM types are supported, each built from a Ubuntu ISO with unattended installation via cloud-init and configured through provisioning scripts over SSH.

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

## Export

`export-ova.ps1` exports a built VM to OVA format using `ovftool`. The VM must be powered off first.

```powershell
.\export-ova.ps1 -VM SIFT
.\export-ova.ps1 -VM REMnux
.\export-ova.ps1 -VM ubuntu-2404
.\export-ova.ps1 -VM SIFT -OutputDir D:\exports
```

Uses `--diskMode=thin` so the OVA only contains written data.

## Lint

```bash
cd packer-ubuntu
make test   # shellcheck on all provisioning scripts
```

---

## WIN-FOR (Windows)

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
| `headless` | `false` | Run without a display window |
| `username` | `forensics` | Local admin account name |
| `password` | `forensics` | Local admin password |
| `winfor_mode` | `dedicated` | WIN-FOR install mode: `addon`, `dedicated`, or `custom` |
| `include_wsl` | `true` | Install SIFT and REMnux inside WSL2 |
| `windows_image_name` | `Windows 11 Pro` | Edition to install (must match `install.wim`) |
| `xways_user` / `xways_pass` | `""` | Optional X-Ways portal credentials |

### Build steps

1. Boots from ISO via UEFI, installs Windows unattended (`Autounattend.xml`)
2. Connects over WinRM and runs the provisioning scripts
3. Takes an `Installed` snapshot
4. Moves the VM to `$VM_DIR`, opens it in VMware, and sets up shared folders
5. Takes a final `Secure` snapshot

### Provisioning scripts

| Script | Role |
| --- | --- |
| `00-fixnetwork.ps1` | Forces network profile to Private so WinRM works |
| `01-vmware-tools.ps1` | Installs VMware Tools from the uploaded ISO |
| `02-disable-defender.ps1` | Disables Windows Defender for the build |
| `03-set-powerplan.ps1` | Sets High Performance power plan |
| `03b-disable-screensaver.ps1` | Disables screensaver and display timeout |
| `04-enable-wsl.ps1` | Enables WSL2 and Virtual Machine Platform features |
| `05-install-dotnet.ps1` | Installs .NET 8 Desktop Runtime (required by WIN-FOR GUI) |
| `06-install-winfor.ps1` | Runs `winfor-cli.ps1` (SaltStack + tools + WSL distros) |
| `99-cleanup.ps1` | Removes temp files, restores UAC |

### Autounattend.xml

The unattended answer file handles:

- **Hardware bypasses** — TPM 2.0, Secure Boot, RAM, CPU, and storage checks disabled so the build works on VMware Workstation without vTPM
- **UEFI/GPT partitioning** — EFI (500 MB) + MSR (16 MB) + Windows (remaining)
- **Local account** — creates the `forensics` admin account, no Microsoft account required
- **Network bypass** — `BypassNRO` skips the mandatory network screen (Win11 22H2+)
- **WinRM setup** — enabled in `FirstLogonCommands` so Packer can connect immediately after first boot
- **Telemetry disabled** — the following are turned off at build time:

| Category | Mechanism |
| --- | --- |
| Telemetry (level 0) | `AllowTelemetry = 0` via policy and DataCollection keys |
| DiagTrack service | `Start = 4` (disabled) |
| DiagTrack AutoLogger | `Start = 0` |
| dmwappushservice | `Start = 4` (disabled) |
| Advertising ID | Policy (HKLM) + user (HKCU) |
| Location services | `LocationAndSensors` policy |
| Cortana / web search | `Windows Search` policy |
| Inking & typing improvement | `InputPersonalization` policy + user keys |
| Windows Error Reporting | Policy + runtime key |
| Activity History / Timeline | `System` policy |
| Consumer features / suggested apps | `CloudContent` policy |
| Tailored experiences | HKCU `Privacy` key |
| Feedback prompts (SIUF) | HKCU `Siuf\Rules` |
