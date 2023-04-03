#!/usr/bin/env bash
set -x
set -e

export TSM_URL=$1
export CSP_TOKEN=$2
export CLUSTER_NAME=$3
export KUBECONFIG=$4



echo "Exchanging API token for access token"
AT=$(curl -s 'https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize' \
            -H 'accept: application/json, text/plain, */*' \
            --data-raw "refresh_token=${CSP_TOKEN}" --compressed | jq -r '.access_token')
echo "$AT"

# Removing Cluster from TSM
echo "Removing Cluster from TSM"
ID=$(curl -X DELETE https://"$TSM_URL"/tsm/v1alpha2/projects/default/clusters/"$CLUSTER_NAME" -H "accept: application/json" \
                   -H "csp-auth-token:$AT" \
                   -H 'content-type: application/json' | jq -r '.id')

echo "Uninstall ID: $ID"

sleep 120
# Get Uninstall Job URL
URL=$(curl -X GET https://"$TSM_URL"/tsm/v1alpha2/projects/default/jobs/"$ID"/download \
       -H "Accept: application/json, text/plain, */*" \
       -H "csp-auth-token: $AT" | jq -r '.url')

echo "Uninstall URL: $URL"
# Removing TSM components from cluster
kubectl delete -f "$URL" --kubeconfig <(echo "$KUBECONFIG" | base64 --decode) --ignore-not-found=true