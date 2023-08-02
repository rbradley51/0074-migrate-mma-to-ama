<#
.SYNOPSIS
Enable automatic upgrade for Azure Monitor Agent (AMA) extension.

.DESCRIPTION
How to enable automatic upgrade for Azure Monitor Agent (AMA) extension for Azure VMs and Azure Arc Servers.

.NOTES
File Name : Enable-AutomaticUpgradeAMA.ps1
Author : Microsoft MVP/MCT - Charbel Nemnom
Version : 1.0
Date : 23-February-2023
Updated : 24-February-2023
Requires : PowerShell 5.1 or PowerShell 7.3.x (Core)
Modules : Az.Accounts, Az.Compute, Az.ConnectedMachine

.LINK
To provide feedback or for further assistance please visit: https://charbelnemnom.com
https://charbelnemnom.com/how-to-enable-automatic-upgrades-for-ama/

.EXAMPLE
.\Enable-AutomaticUpgradeAMA.ps1 -environment [AzVM, AzArc] -Verbose
This example will connect to your Azure account, then loop through all the subscriptions that you have,
And then check the Azure Monitor Agent for Windows and Linux VMs that have AMA extension installed but automatic upgrade is NOT enabled.
#>

param (
[Parameter(Mandatory)]
[ValidateSet("AzVM", "AzArc")]
[String]$Environment = 'AzVM'
)

#! Install Az Module If Needed
function Install-Module-If-Needed {
param([string]$ModuleName)
if (Get-Module -ListAvailable -Name $ModuleName -Verbose:$false) {
Write-Host "Module '$($ModuleName)' already exists, continue..." -ForegroundColor Green
}
else {
Write-Host "Module '$($ModuleName)' does not exist, installing..." -ForegroundColor Yellow
Install-Module $ModuleName -Force -AllowClobber -ErrorAction Stop
Write-Host "Module '$($ModuleName)' installed." -ForegroundColor Green
}
}

#! Install Az Accounts Module If Needed
Install-Module-If-Needed Az.Accounts

#! Install Az Compute Module If Needed
Install-Module-If-Needed Az.Compute

#! Install Az ConnectedMachine Module If Needed
Install-Module-If-Needed Az.ConnectedMachine

#! Check Azure Connection
Try {
Write-Verbose "Connecting to Azure Cloud..."
Connect-AzAccount -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
}
Catch {
Write-Warning "Cannot connect to Azure Cloud. Please check your credentials. Exiting!"
Break
}

$azSubs = Get-AzSubscription

foreach ( $azSub in $azSubs ) {
$azSubName = $azSub.Name
Write-Verbose "Set the Azure context to the subscribtion name: $($azSubName)"
Set-AzContext -Subscription $azSub | Out-Null

If ($environment -eq "AzVM") {
$azVMs = Get-AzVM -ErrorAction SilentlyContinue
If ($azVMs) {
Write-Verbose "Get the list of all Azure VMs that have AMA extension installed and Automatic Upgrade is NOT enabled..."
$amas = @()

foreach ($azVM in $azVMs) {
$amas += Get-AzVMExtension -VMName $azVM.Name -ResourceGroupName $azVM.ResourceGroupName | `
Where-Object { $_.Publisher -eq "Microsoft.Azure.Monitor" -and $_.EnableAutomaticUpgrade -eq $False }
}

If ($amas) {
foreach ($ama in $amas) {
Write-Verbose "Enable Automatic Upgrade for the AMA extension for the Azure VM: $($ama.VMName)"
$ama | Set-AzVMExtension -EnableAutomaticUpgrade $True | Out-Null
}
}
else {
Write-Verbose "All Azure VMs have Automatic Upgrade Extension enabled for AMA!"
}

}
else {
Write-Verbose "No Azure VMs found for the subscribtion name: $($azSubName)!"

}

If ($environment -eq "AzArc") {
$azVMs = Get-AzConnectedMachine -ErrorAction SilentlyContinue
If ($azVMs) {
Write-Verbose "Get the list of all Azure Arc Servers that have AMA extension installed and Automatic Upgrade is NOT enabled..."
$amas = @()

foreach ($azVM in $azVMs) {
$amas += Get-AzConnectedMachineExtension -MachineName $azVM.Name -ResourceGroupName $azVM.ResourceGroupName | `
Where-Object { $_.Publisher -eq "Microsoft.Azure.Monitor" -and $_.EnableAutomaticUpgrade -eq $False }
}

If ($amas) {
foreach ($ama in $amas) {
$machineName = $ama.id.Split('/')[-3]
Write-Verbose "Enable Automatic Upgrade for the AMA extension for Azure Arc Server: $($machineName)"
$ama | Update-AzConnectedMachineExtension -EnableAutomaticUpgrade | Out-Null
}
}
else {
Write-Verbose "All Azure Arc Servers have Automatic Upgrade Extension enabled for AMA!"
}
}
else {
Write-Verbose "No Azure Arc Servers found for the subscribtion name: $($azSubName)!"
}

}
}
}