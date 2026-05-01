$ErrorActionPreference = "Stop"

# WinRM refuses connections on network profiles set to Public. After each reboot
# Windows may re-classify the VM's vmxnet3 adapter as "Unidentified network" and
# default its profile to Public, breaking subsequent Packer provisioner steps.
# This script forces all network connections to Private via the INetwork COM interface.

Write-Output "Setting all network connections to Private..."

$networkListManager = [Activator]::CreateInstance(
    [Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}")
)

foreach ($conn in $networkListManager.GetNetworkConnections()) {
    $name     = $conn.GetNetwork().GetName()
    $category = $conn.GetNetwork().GetCategory()
    # 0 = Public, 1 = Private, 2 = Domain
    if ($category -ne 1) {
        Write-Output "  $name : category $category -> 1 (Private)"
        $conn.GetNetwork().SetCategory(1)
    } else {
        Write-Output "  $name : already Private"
    }
}

exit 0
