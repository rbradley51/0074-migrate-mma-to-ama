$vmList = (Get-AzVM -ResourceGroupName $env:rgpName).Name
ForEach ($vmName in $vmList) 
{
    $os = Get-AzVM -ResourceGroupName $env:rgpName -Name $vmName | Select-Object -ExpandProperty StorageProfile | Select-Object -ExpandProperty OsDisk | Select-Object -ExpandProperty OsType
    if ($os -eq "Windows")
    {
        $SystemFreeSpaceInGB = "((Get-PSDrive -PSProvider FileSystem -Name 'C').Free/1GB)"
    }
    else
    {
        $SystemFreeSpaceInGB = "((Get-PSDrive -PSProvider FileSystem -Name '/').Free/1GB)"
    }
    $output = Invoke-AzVMRunCommand -ResourceGroupName $env:rgpName -Name $vmName -CommandId 'RunPowerShellScript' -ScriptString $SystemFreeSpaceInGB
    $output.Value[0].Message
}

