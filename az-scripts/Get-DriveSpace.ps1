$vmList = (Get-AzVM -ResourceGroupName $env:rgpName).Name
ForEach ($vmName in $vmList) 
{
    $SystemFreeSpaceInGB = "((Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match $env:SystemDrive[0] }).Free/1GB)"
    $output = Invoke-AzVMRunCommand -ResourceGroupName $env:rgpName -Name $vmName -CommandId 'RunPowerShellScript' -ScriptString $SystemFreeSpaceInGB
    $output.Value[0].Message
}

