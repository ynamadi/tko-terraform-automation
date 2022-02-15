#!/bin/sh
SUBSCRIPTION_ID=$(az account show --query id)
SUBSCRIPTION_ID="${SUBSCRIPTION_ID%\"}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID#\"}"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"  -o yaml &> test.txt
az account show --query id > account1.txt
sed '1s/^/subscription_id = /' account1.txt > account.tfvars
sed 's/: /\t=\t"/g' test.txt > test.tf
sed '/^WARNING/d' test.tf > vars.tf
sed 's/$/"/' vars.tf > tvars.tfvars
sort -n account.tfvars tvars.tfvars > terraform.tfvars
rm test.txt
rm test.tf
rm vars.tf
rm account1.txt
rm account.tfvars
rm tvars.tfvars