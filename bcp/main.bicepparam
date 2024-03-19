using './main.bicep'

param managementGroupName = 'org-id-platform'
param iacSubscriptionId = 'e25024e7-c4a5-4883-80af-9e81b2f8f689'
param iacResourceGroup = 'rgp-iac'
param identityResourceGroup = 'rgp-idy'
param identitySubId = '1d790e78-7852-498d-8087-f5d48686a50e'
param managementSubId = '019181ad-6356-46c6-b584-444846096085'
param managementResourceGroup = 'org-id-mgmt'
param connectivitySubId = 'e4aad2d8-e670-4807-bf53-63b4a36e0d4a'
param connectivityResourceGroup = 'rg-connectivity'
param hubVnetName = 'vnet-hub'
param lawName = 'log-management'
param aaaName = 'aa-management'
param rootMgName = 'org-name'
param umiPrefix = 'umi'
param primaryLocation = 'centralus'
param userName  = null
param vgpPw  = null
param keyVaultSecret = getSecret('e25024e7-c4a5-4883-80af-9e81b2f8f689', 'rgp-iac', 'kvt-1322', 'kvtPw')
