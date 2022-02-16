#!/bin/sh
SUBSCRIPTION_ID=$(az account show --query id)
SUBSCRIPTION_ID="${SUBSCRIPTION_ID%\"}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID#\"}"
az account set --subscription "${SUBSCRIPTION_ID}"
mv ~/.kube/config ~/.kube/configOld
az aks get-credentials --resource-group default --name "$CLUSTER_NAME"
cat ~/.kube/config > config.yaml
mv ~/.kube/configOld ~/.kube/config