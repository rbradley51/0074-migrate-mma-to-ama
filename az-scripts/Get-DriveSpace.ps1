$vmList = (Get-AzVM -ResourceGroupName $env:rgpName).Name
ForEach ($vmName in $vmList) 
{
    # $SystemFreeSpaceGt10GB = "((Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match $env:SystemDrive[0] }).Free/1GB -gt 10)"
    $SystemFreeSpace = "((Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match $env:SystemDrive[0] }).Free/1GB)"
    Invoke-AzVMRunCommand -ResourceGroupName $env:rgpName -Name $vmName -CommandId 'RunPowerShellScript' -ScriptString $SystemFreeSpace -Verbose
    # Invoke-AzVMRunCommand -ResourceGroupName $env:rgpName -Name $vmName -CommandId 'RunPowerShellScript' -ScriptString $SystemFreeSpaceGt10GB -Verbose
}

