#!/usr/bin/env bash
set -x
set -e

export TSM_URL=$1
export TSM_TOKEN=$2
export CLUSTER_NAME=$3


echo "$TSM_URL"
echo "$TSM_TOKEN"
echo "$CLUSTER_NAME"
echo "Exchanging API token for access token"
AT=$(curl -s 'https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize' \
            -H 'accept: application/json, text/plain, */*' \
            --data-raw "refresh_token=${TSM_TOKEN}" --compressed | jq -r '.access_token')
echo "$AT"

# Removing Cluster from TSM
echo "Removing Cluster from TSM"
ID=$(curl -X DELETE https://"$TSM_URL"/tsm/v1alpha1/clusters/"${CLUSTER_NAME}" -H "accept: application/json" \
                   -H "csp-auth-token:$AT" \
                   -H 'content-type: application/json' | jq -r '.id')
echo "$ID"
echo "Setting initial state to init"
STATE="INIT"
sleep 60
# Check Job Status
until [[ $STATE == "Completed" ]]
do
    echo "${CLUSTER_NAME} State = ${STATE}, waiting..."
    sleep 15
    STATE=$(curl -X GET https://"$TSM_URL"/tsm/v1alpha1/jobs/"$ID" \
                   -H "Accept: application/json, text/plain, */*" \
                   -H "csp-auth-token: $AT" | jq -r '.state')
done

# Get Uninstall Job URL
URL=$(curl -X GET https://"$TSM_URL"/tsm/v1alpha1/jobs/"$ID"/download \
       -H "Accept: application/json, text/plain, */*" \
       -H "csp-auth-token: $AT" | jq -r '.url')

# Removing TSM components from cluster
echo "Removing TSM components from cluster $1 using url $URL"
kubectl delete --ignore-not-found=true -f "$URL"
echo 'Cluster '"${CLUSTER_NAME}"' has been Removed from TSM'