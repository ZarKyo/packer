$ErrorActionPreference = "Stop"

# High Performance scheme + zero out every sleep/timeout. The WIN-FOR install
# can take several hours, and we do not want the VM to suspend mid-build.

$HIGH_PERF = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

Write-Output "Activating High Performance power plan"
powercfg /setactive $HIGH_PERF

Write-Output "Zeroing out sleep / display / disk timeouts (AC and DC)"
powercfg /change monitor-timeout-ac   0
powercfg /change monitor-timeout-dc   0
powercfg /change disk-timeout-ac      0
powercfg /change disk-timeout-dc      0
powercfg /change standby-timeout-ac   0
powercfg /change standby-timeout-dc   0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0

Write-Output "Disabling hibernate"
powercfg /hibernate off

exit 0
