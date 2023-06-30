#!/bin/bash
# This script creates a new user-assigned managed identity and assignes it to a set of roles on a given scope.
roles=("Virtual Machine Contributor" "Log Analytics Contributor" "Azure Arc Connected Resource Administrator")
az group create -n $uamiResourceGroup -l $uamiLocation;
rgId=$(az group show --name $uamiResourceGroup --query "id" -o tsv)
az identity create -g $uamiResourceGroup -n $uamiName --query id -o tsv;
for role in "${roles[@]}";
   do echo $role;
   az role assignment create --role "$role" --assignee $uamiName --scope $rgId;
done
