#!/bin/bash
# This script creates a new user-assigned managed identity and assignes it to a set of roles on a given scope.
roles=("Virtual Machine Contributor" "Log Analytics Contributor" "Azure Connected Machine Resource Administrator")
# az account set -s $AZURE_SUBSCRIPTION_ID
az group create -n $uamiResourceGroup -l $uamiLocation;
rgId=$(az group show --name $uamiResourceGroup --query "id" -o tsv)
az identity create -g $uamiResourceGroup -n $uamiName --query id -o tsv;
uamiId=$(az identity list -g $uamiResourceGroup --query [].principalId -o tsv)
for role in "${roles[@]}";
   do echo $role;
   az role assignment create --role "$role" --assignee-object-id $uamiId --assignee-principal-type ServicePrincipal --scope $rgId;
done
