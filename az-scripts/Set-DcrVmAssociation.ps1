# Add header# Add header to the script
<#
.SYNOPSIS
	Create a set of DCR to VM associations based on the content specified in a CSV input file for DCRs and VMs.
.DESCRIPTION
	This script will ingest and process a CSV mapping of DCRs and VMs to associate a set of VMs with a specific DCR 
.PARAMETER inputFilePath 
	Path of input file to ingest and process
.EXAMPLE
	Get-DcrVmAssociation -inputFilePath <inputFilePath>
.NOTES
	File Name      : Get-DcrVmAssociation.ps1
	Author         : Preston K. Parsard
	Prerequisite   : PowerShell Core
#>

[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$inputFilePath = "./input/"
)

 $inputList = (Import-Csv -Path $inputFilePath)
 for (each $input in $inputList) 
 {
	$index = $input.index 
	$vmi = $input.vmId 
	 $dci = $input.dcrResourceId

	 $vmIdSub = $input.vmId.Split("/")[2]
	 $vmIdRgp = $input.vmId.Split("/")[4]
	 $vmName = $input.vmId.Split("/")[-1]

	 $dcrSub = $input.dcrResourceId.Split("/")[2]
	 $dcrRgp = $input.dcrResourceId.Split("/")[4]
	 $dcrName = $input.dcrResourceId.Split("/")[-1]

	 $associationName = "$dcrName-$vmName-association"
	 $description = $assocationName
	 Write-Host "$index `t Assigning $vmName in resource group $vmIdRgp to data collection rule $dcrName in resource group $dcrRgp"
	 New-AzDataCollectionRuleAssociation -Name $assocationName -ResourceGroupName $dcrRgp -RuleId $dci -Description $description -AssociationResourceId $vmi -Verbose
 }




