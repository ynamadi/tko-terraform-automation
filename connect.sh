#!/bin/sh
az aks get-credentials --resource-group $1 --name $2 -f config-aks-cluster.yaml