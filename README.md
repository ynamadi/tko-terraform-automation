# tmc-attach-aks-cluster
run `./config.sh` to gather credentials
execute: 
```
terraform init|plan|apply|destroy  
    -var cluster_name=testcluster1 \
    -var vmw_host=<YOUR_ORG>.tmc.cloud.vmware.com \
    -var vmw_api_token=<YOUR_TOKEN>
```