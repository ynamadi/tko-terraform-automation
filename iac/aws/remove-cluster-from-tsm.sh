#!/usr/bin/env bash
set -x
set -e

export TSM_URL=$1
export CSP_TOKEN=$2
export CLUSTER_NAME=$3
export KUBECONFIG=$4

# Get Access Token
echo "Exchanging API token for access token"
AT=$(curl -s 'https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize' \
            -H 'accept: application/json, text/plain, */*' \
            --data-raw "refresh_token=${CSP_TOKEN}" --compressed | jq -r '.access_token')
echo "$AT"


# Delete Cluster on SaaS and return job ID
ID=$(curl -X DELETE https://"$TSM_URL"/tsm/v1alpha2/projects/default/clusters/"$CLUSTER_NAME" \
                   -H "accept: application/json" \
                   -H "csp-auth-token:$AT" | jq -r '.id')
echo "$ID"

sleep 120

# Get Uninstall Job URL
URL=$(curl -X GET https://"$TSM_URL"/tsm/v1alpha2/projects/default/jobs/"$ID"/download \
       -H "Accept: application/json, text/plain, */*" \
       -H "csp-auth-token: $AT" | jq -r '.url')

# Removing TSM components from cluster
echo "Removing TSM components from cluster $CLUSTER_NAME using url $URL"
kubectl delete -f "$URL" --kubeconfig <(echo "$KUBECONFIG" | base64 --decode) --ignore-not-found=true