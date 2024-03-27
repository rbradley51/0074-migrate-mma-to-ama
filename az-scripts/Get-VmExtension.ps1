Select-AzSubscription -SubscriptionId $env:idySubscription
$vmList = (Get-AzVM -ResourceGroupName $env:rgpName).Name
foreach ($vmName in $vmList) {
    $vmExtensions = (Get-AzVMExtension -ResourceGroupName $env:rgpName -VMName $env:vmName).Name
    if (($vmExtensions -contains 'MicrosoftMonitoringAgent') -and ($vmExtensions -contains 'AzureMonitoringWindowsAgent')) {
        Write-Host "VM: $vmName, both the MMA AND AMA extensions ARE installed"
        if ($env:removeLegacyAgent -eq "true") 
        {
            Write-Host "Removing MMA extension from VM: $vmName"
            if ($env:removeMMA -eq "true")
            {
                Remove-AzVMExtension -ResourceGroupName $env:rgpName -VMName $vmName -Name "MicrosoftMonitoringAgent" -Confirm:$false -Force -Verbose
            } 
            else 
            {
                Write-Host "MMA extension removal skipped for VM: $vmName"
                Remove-AzVMExtension -ResourceGroupName $env:rgpName -VMName $vmName -Name "MicrosoftMonitoringAgent" -WhatIf -Verbose
            }
        }
    }
    elseif (($vmExtensions -contains 'MicrosoftMonitoringAgent') -and !($vmExtensions -contains 'AzureMonitoringWindowsAgent')){
        Write-Host "VM: $vmName, Only the MMA extension IS installed"
    }
    elseif (($vmExtensions -contains 'AzureMonitoringWindowsAgent') -and !($vmExtensions -contains 'MicrosoftMonitoringAgent')) 
    {
        Write-Host "VM: $vmName, Only the AMA extension IS installed"
    }
    else 
    {
        Write-Host "VM: $vmName, neither the MMA nor AMA extensions ARE installed"
    }
}