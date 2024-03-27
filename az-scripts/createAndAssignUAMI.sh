#!/bin/bash
# This script creates a new user-assigned managed identity and assignes it to a set of roles on a given scope.

roles=("Virtual Machine Contributor" "Log Analytics Contributor" "Azure Connected Machine Resource Administrator")
# if resource group exists, skip creation
existingRgp=$(az group list --query [].name -o tsv)
if [[ $existingRgp == *$uamiResourceGroup* ]]; then
   echo "Resource group $uamiResourceGroup already exists. Skipping creation."
else
   echo "Creating resource group $uamiResourceGroup"
   az group create -n $uamiResourceGroup -l $uamiLocation;
fi

existingIdentiy=$(az identity list --query [].name -o tsv)
if [[ $existingIdentiy == *$uamiName* ]]; then
   echo "Identity $uamiName already exists. Skipping creation."
else
   echo "Creating identity $uamiName"
   az identity create -g $uamiResourceGroup -n $uamiName --query id -o tsv;
fi

rgId=$(az group show --name $uamiResourceGroup --query "id" -o tsv)
uamiId=$(az identity show -g $uamiResourceGroup -n $uamiName --query principalId -o tsv)

for role in "${roles[@]}";
   do echo $role;
   az role assignment create --role "$role" --assignee-object-id $uamiId --assignee-principal-type ServicePrincipal --scope $rgId;
done

az subscription set --subscription $idySubscrption --verbose
vmNames=$(az vm list -g $rgpName --query "[].name" -o tsv)
for vm in $vmNames;
   do echo $vm;
   az vm identity assign -g $rgpName -n $vm --identities $uamiId --verbose;
   osType=$(az vm show -g $rgpName -n $vm --query "storageProfile.osDisk.osType" -o tsv)
   if [[ $osType == "Windows" ]]; then
      # Your code here for Windows OS
      echo "Performing actions for Windows OS"
      az vm extension set -n "AzureMonitorWindowsAgent" --publisher "Microsoft.Azure.Monitor" --vm-name $vm -g $rgpName --version 1.24 --enable-auto-upgrade --verbose;
      # Your code here for non-Windows OS
      echo "Performing actions for Linux OS"
      az vm extension set -n AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor --vm-name $vm -g $rgpName --version 1.30 --verbose;
   fi
done
```