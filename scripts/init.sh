#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

resourceGroupName="$1"

if [ -z "$resourceGroupName" ]; then
  echo "Usage: $0 <resource-group-name>"
  exit 1
fi

subscriptionId=$(az account show --query id -o tsv)
userObjectId=$(az ad signed-in-user show --query id -o tsv)
location="centralindia"
storageAccountName="${resourceGroupName}uibariu$(openssl rand -hex 4)"
containerName="terraformstate"

echo "Creating Azure resources for Terraform backend..."

echo "Creating resource group $resourceGroupName in $location..."
az group create --name $resourceGroupName --location $location

echo "Creating storage account $storageAccountName..."
az storage account create \
  --name $storageAccountName \
  --resource-group $resourceGroupName \
  --location $location \
  --sku Standard_LRS

echo "Creating blob container $containerName..."
az storage container create \
  --name $containerName \
  --account-name $storageAccountName

echo "Generating SAS token for storage account..."
sasToken=$(az storage account generate-sas \
  --permissions acdlrw \
  --account-name $storageAccountName \
  --services b \
  --resource-types sco \
  --expiry $(date -u -d '365 days' +%Y-%m-%dT%H:%MZ) \
  --output tsv)

echo "Creating Key Vault $resourceGroupName..."
az keyvault create \
  --name $resourceGroupName \
  --resource-group $resourceGroupName \
  --location $location \
  --sku standard \
  --enable-rbac-authorization false

echo "Set Access Policies for the current user..."
az keyvault set-policy \
  --name $resourceGroupName \
  --object-id $userObjectId \
  --secret-permissions get list set delete recover backup restore purge

backendConfig=$(cat <<EOT
terraform {
    backend "azurerm" {
        storage_account_name = "$storageAccountName"
        container_name       = "$containerName"
        key                  = "terraform.tfstate"
        sas_token            = "$sasToken"
    }
}

variable "azure_subscription_id" {
  type    = string
  default = "$subscriptionId"
}
EOT
)

echo "Saving backend configuration to Key Vault..."
az keyvault secret set \
  --vault-name $resourceGroupName \
  --name "remote-backend-config" \
  --value "$backendConfig"

echo "Saving backend configuration to backend.tf..."
az keyvault secret show --vault-name $resourceGroupName --name remote-backend-config --query value --output tsv > backend.tf

echo "Azure resources for Terraform backend are configured."