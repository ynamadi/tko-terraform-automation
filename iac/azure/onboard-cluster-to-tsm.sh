#!/usr/bin/env bash
set -x
set -e

export TSM_URL=$1
export CSP_TOKEN=$2
export CLUSTER_NAME=$3
export KUBECONFIG=$4


# Exchange CSP API Token for Access Token
echo "Exchanging API token for access token"
AT=$(curl -s 'https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize' \
            -H 'accept: application/json, text/plain, */*' \
            --data-raw "refresh_token=${CSP_TOKEN}" --compressed | jq -r '.access_token')
echo "$AT"

# Create Cluster Objects and Retrieve Token for Secret
echo "Creating Cluster Object and Getting TSM Token for Secret"
TOKEN=$(curl -X PUT "https://$TSM_URL/tsm/v1alpha2/projects/default/clusters/${CLUSTER_NAME}?createOnly=true" \
                   -H "csp-auth-token:$AT" \
                   -H 'content-type: application/json' \
                   -d '{"displayName": "'"${CLUSTER_NAME}"'", "description":"Test cluster", "tags":["msp-dc", "vsphere"], "labels":[{"key":"Proxy Location", "value":"aviproxy"}], "autoInstallServiceMesh":true, "enableNamespaceInclusions":true, "enableInternalGateway":false, "namespaceInclusions":[{"type": "EXACT", "match": "acme"}], "autoInstallServiceMeshConfig":{"restrictDefaultExternalAccess":false}}' \
                   | jq -r '.token')

sleep 5

# Get Onboarding URL for Cluster
echo "Fetching Onboarding URL"
# old v1alpha1 call

ONBOARD_URL=$(curl https://"$TSM_URL"/tsm/v1alpha2/projects/default/clusters/"$CLUSTER_NAME"/onboarding-url \
                  -H "csp-auth-token:$AT" | jq -r '.url')


# Apply Onboarding Manifest
kubectl apply -f "$ONBOARD_URL" --kubeconfig <(echo "$KUBECONFIG" | base64 --decode)

# Create Secret from Token
echo "Creating Secret from TSM Token"
kubectl -n vmware-system-tsm create secret generic cluster-token --from-literal=token="$TOKEN" --kubeconfig <(echo "$KUBECONFIG" | base64 --decode)

