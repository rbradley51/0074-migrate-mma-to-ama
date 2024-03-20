$env:rgpLocation = "centralus"
$endpointList = @(
    "global.handler.control.monitor.azure.com",
    "$env:rgpLocation.handler.control.monitor.azure.com",
    "$env:lawId.ods.opinsights.azure.com"
)

$vmList = (Get-AzVM -ResourceGroupName $env:rgpName).Name
ForEach ($vmName in $vmList) 
{
    Write-Host ("="*100)
    ForEach ($endpoint in $endpointList)
    {
        Write-Host ("-"*100)
        $ScriptString = "(Test-Connection -ComputerName $endpoint -Count 1).Status"
        $output = Invoke-AzVMRunCommand -ResourceGroupName $env:rgpName -Name $vmName -CommandId 'RunPowerShellScript' -ScriptString $ScriptString
        $connectionResult = $output.Value[0].Message
        Write-Host "VM: $vmName, Endpoint: $endpoint, Connection-Result: $connectionResult"
    }
}