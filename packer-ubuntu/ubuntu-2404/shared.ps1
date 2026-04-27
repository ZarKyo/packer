. ../../defaults.ps1

$VM = "ubuntu-2404"

Start-VM $VM | Out-Null

Enable-SharedFolders $VM

Add-SharedFolder $VM $SHARED_RO_NAME $SHARED_RO_PATH "readonly" | Out-Null
Add-SharedFolder $VM $SHARED_RW_NAME $SHARED_RW_PATH "writable" | Out-Null

Stop-VM $VM | Out-Null