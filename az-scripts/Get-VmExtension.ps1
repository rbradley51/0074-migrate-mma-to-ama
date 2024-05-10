Select-AzSubscription -SubscriptionId $env:IDYSUBSCRIPTION
$vmList = (Get-AzVM -ResourceGroupName $env:rgpName).Name
$mma = "MicrosoftMonitoringAgent"
$ama = "AzureMonitorWindowsAgent"
foreach ($vmName in $vmList) {
    $vmExtensions = (Get-AzVMExtension -ResourceGroupName $env:rgpName -VMName $vmName).Name
    if (($vmExtensions -contains $mma) -and ($vmExtensions -contains $ama)) {
        Write-Host "VM: $vmName, both the MMA AND AMA extensions ARE installed"
        if ($env:removeLegacyAgent -eq "true") 
        {
            Write-Host "Removing MMA extension from VM: $vmName"
            if ($env:removeMMA -eq "true")
            {
                Remove-AzVMExtension -ResourceGroupName $env:rgpName -VMName $vmName -Name $mma -Confirm:$false -Force -Verbose
            } 
            else 
            {
                Write-Host "MMA extension removal skipped for VM: $vmName"
                Remove-AzVMExtension -ResourceGroupName $env:rgpName -VMName $vmName -Name $mma -WhatIf -Verbose
            }
        }
    }
    elseif (($vmExtensions -contains 'MicrosoftMonitoringAgent') -and !($vmExtensions -contains $ama)){
        Write-Host "VM: $vmName, Only the MMA extension IS installed"
    }
    elseif (($vmExtensions -contains $ama) -and !($vmExtensions -contains $mma)) 
    {
        Write-Host "VM: $vmName, Only the AMA extension IS installed"
    }
    else 
    {
        Write-Host "VM: $vmName, neither the MMA nor AMA extensions ARE installed"
    }
}