#!/bin/bash -x

# Terraform, azure cli e aks

#brew install terraform && brew update && brew install azure-cli

# To run this script, you need to export the following variables:
# export client_id=app_id_service_principal
# export client_secret=password_service_principal

# Create ssh keys
echo -ne '\n' | ssh-keygen

# Create storage account to save the terraform tfstate file:
resourceGroup="rgtfstate"
region="eastus"
storagename="sttfstate"
sku="Standard_GRS"

RGACCOUNT=$(az group exists -n $resourceGroup)
if [ $RGACCOUNT == "true" ]; then
    printf "\\nO resource group especificado já existe\\n";
else
    az group create --name "$resourceGroup" --location "$region"
fi

STACCOUNT=$(az storage account list -g "$resourceGroup" | jq -r '.[].name')
if [ $STACCOUNT == $storagename ]; then
    printf "\\nThe specified resource group already exists\\n";
else
    az storage account create --location "$region" --name "$storagename" --resource-group "$resourceGroup" --sku "$sku"
fi

# After the storage account is created, two access keys will be generated: key1 and key2, which can be obtained through the command below:
keyvalue=$(az storage account keys list -g "$resourceGroup" -n "$storagename" | grep -m1 value | awk '{print $2}')
echo "$keyvalue"

# The keys generated through the previous command will be used to create the container where the tfstate file of terraform will be:
az storage container create -n tfstate --account-name "$storagename" --account-key "$keyvalue"

# If all previous steps have occurred successfully, we can create the cluster using terraform:
TF_LOG=DEBUG terraform init -backend-config="storage_account_name=$storagename" -backend-config="container_name=tfstate" -backend-config="access_key=$keyvalue" -backend-config="key=aksteste.tfstate" 

# Create the terraform plan with the command terraform plan to define the elements of the infrastructure, where var.client_id is the appId and var.client_secret is the access key:
TF_LOG=DEBUG terraform plan -out aks.plan -var client_id=$client_id -var client_secret=$client_secret

# Create the kubernetes cluster using the terraform apply command:
TF_LOG=DEBUG terraform apply aks.plan

# To manage the cluster through the kubernetes UI:
#az aks browse --resource-group rgk8spoc --name k8spoc