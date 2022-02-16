#!/bin/sh
az aks get-credentials --resource-group $1 --name $2 -f ~/.kube/config-aks-cluster.yaml