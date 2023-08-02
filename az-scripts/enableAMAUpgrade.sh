#!/bin/bash
# This script enables the Azure Monitor Agent auto-upgrade on all VMs in a resource group

vms=$(az vm list -g $rgpName --query [].name -o tsv)

for vm in "${vms[@]}";
   do echo $vm;
   az vm extension set --name AzureMonitorWindowsAgent --publisher Microsoft.Azure.Monitor --vm-name $vm --resource-group $rgpName --enable-auto-upgrade true;
done