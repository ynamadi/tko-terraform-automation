#!/bin/sh

#Retrieve subscription id
SUBSCRIPTION_ID=$(az account show --query id | tr -d '"')

#Create a Service Principle and write the client_id, client_secret, tenant_id, subscription_id to terraform.tfvars file
az ad sp create-for-rbac --name "azure-cli-sp-$(date +%Y)-$(date +%m)-$(date +%d)-$(date +%H)-$(date +%M)-$(date +%S)" --role Contributor --scopes /subscriptions/"$SUBSCRIPTION_ID" --query "{client_id:appId, client_secret:password, tenant_id:tenant}" -o yaml >> temp.tfvars
echo "subscription_id: $SUBSCRIPTION_ID" >> temp.tfvars

#Format terraform.tfvars file
sed 's/: /\t=\t"/; s/$/"/'  temp.tfvars > terraform.tfvars

# Cleaning up temp files
rm temp.tfvars