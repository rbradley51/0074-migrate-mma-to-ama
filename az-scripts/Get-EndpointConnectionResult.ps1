$env:rgpLocation = "centralus"
$endpointList = @(
    "global.handler.control.monitor.azure.com",
    "$env:rgpLocation.handler.control.monitor.azure.com",
    "$env:lawId.ods.opinsights.azure.com"
)

Write-Verbose "The following endpoints must be reachable from the each VM:"
$endpointList 