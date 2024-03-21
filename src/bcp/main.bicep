targetScope = 'managementGroup'

/*
1. az stack group create --name ds02 --description 'testing-no-prompt-with-az-cli' -g rgp-idy --delete-all -f ./main-plt-idy.bicep -p ./main-plt-idy.parameters.json --deny-settings-mode none --yes --verbose
2. az stack group delete --name ds02 --delete-all -g rgp-idy --verbose 
3. NOTE: For the  PowerShell command to remove a deployment, the -Confirm:$false parameter doesn't seem to be working:
   Remove-AzResourceGroupDeploymentStack -Name ds01 -ResourceGroupName rgp-idy -DeleteAll -Confirm:$false -Verbose
4. Create a deployment stack using parameters from key/value pairs
az stack group create --name StackName --template-file simpleTemplate.json --resource-group ResourceGroup --description description --parameters simpleTemplateParams.json value1=foo value2=bar --deny-settings-mode None
*/

@description('Name of platform management group')
param managementGroupName string
@description('Id of IAC subscription')
param iacSubscriptionId string
@description('Name of IAC resource group')
param iacResourceGroup string
param identityResourceGroup string
param identitySubId string
param managementSubId string
param managementResourceGroup string
param connectivitySubId string
param connectivityResourceGroup string
param hubVnetName string
param lawName string
param aaaName string
param rootMgName string
param umiPrefix string
param primaryLocation string
param userName string
@secure()
param vgpPw string
@secure()
param kvtPw string 
param bicepRegistryName string = 'autocloudarc'
param acrSku string = 'Basic'

// Use a ternary operator to set the value of pw based on the null condition of vgpPw
// var pw = (vgpPw == null) ? kvtPw : vgpPw

module sta './modules/sbx/sta.bicep' = {
  name: 'storage'
  scope: resourceGroup(identitySubId, identityResourceGroup)
  params: {
    primaryLocation: primaryLocation
    storageAccountNamePrefix: 'sbx'
    storageAccountType: 'Standard_LRS'
    storageAccountKind: 'StorageV2'
    staAccessTier: 'Hot'
  }
}


module iac 'modules/iac/iac.bicep' = {
  scope: resourceGroup(iacSubscriptionId, iacResourceGroup)
  name: 'iac'
  params: {
    primaryLocation: primaryLocation
    bicepRegistryName: bicepRegistryName
    acrSku: acrSku
  }
}

module idy 'modules/plt/idy/idy.bicep' = {
  scope: resourceGroup(identitySubId, identityResourceGroup)
  name: 'idy'
  params: {
    primaryLocation: 'centralus'
    storageAccountNamePrefix: 'sta'
    storageAccountType: 'Standard_LRS'
    storageAccountKind: 'StorageV2'
    staAccessTier: 'Hot'
    containerName: 'azr-ama-container'
    managementSubId: managementSubId
    managementResourceGroup: managementResourceGroup
    connectivitySubId: connectivitySubId
    connectivityResourceGroup: connectivityResourceGroup
    hubVnetName: hubVnetName
    lawName: lawName
    aaaName: aaaName
    rootMgName: rootMgName
    umiPrefix: umiPrefix
    userName: userName
    pw: kvtPw
  }
}

module net 'modules/plt/net/net.bicep' = {
  scope: resourceGroup(connectivitySubId, connectivityResourceGroup)
  name: 'net'
  dependsOn: [idy]
  params: {
    primaryLocation: 'centralus'
    hubVnetName: hubVnetName
    idyVnetId: idy.outputs.idyVnetId
    lawName: lawName
    identitySubId: identitySubId
    identityResourceGroup: identityResourceGroup
  }
}

output idyStaName string = idy.outputs.storageAccountName
output mgName string = managementGroupName
output hubVnetId string = idy.outputs.hubVnetId
output lawId string = idy.outputs.lawId
output aaaId string = idy.outputs.aaaId
output variableGroupPw string = vgpPw
