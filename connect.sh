#!/bin/sh
SUBSCRIPTION_ID=$(az account show --query id)
SUBSCRIPTION_ID="${SUBSCRIPTION_ID%\"}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID#\"}"
az account set --subscription "${SUBSCRIPTION_ID}"
mv ~/.kube/config ~/.kube/configOld
az aks get-credentials --resource-group default --name test0001
cat ~/.kube/config > config.yaml
mv ~/.kube/configOld ~/.kube/config