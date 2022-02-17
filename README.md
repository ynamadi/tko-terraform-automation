# Attaching an AKS Cluster to Tanzu Mission Control

This script is designed to create an AKS Cluster and attach it to Tanzu Mission Control

#### Note: TMC provider requires Terraform version 0.15 or later, the provider supports static credentials passed to the provider or environment variables.

### **Authenticating to TMC**

Passing the static credentials to the provider
```terraform
provider "tanzu-mission-control" {
  endpoint            = "my-company.tmc.cloud.vmware.com"
  vmw_cloud_api_token = "Super secret API Token string"
}
```

Passing credentials via environment variable
```shell
export TMC_API_TOKEN="my-company.tmc.cloud.vmware.com"
export TMC_ORG_URL="Super secret API Token string"
```
```terraform
provider "tanzu-mission-control" {}
```

1. Authenticating via Azure Cli
```shell
az login
```

2. Creating Service Principle Identity and writing variables to terraform.tfvars file
```shell
./config.sh
```

3. Initialize working directory and upgrade modules
```shell
terraform init -upgrade
```

4. Review changes prior to applying

#### **ENV Variables**:
* CLUSTER_NAME -- Name of the AKS cluster to be created
* HOST -- TMC host to attach the cluster  i.e. my-team.tmc.cloud.vmware.com
* API_TOKEN -- TMC API Token, this could be generated from TMC --> User Account Settings --> My Account --> API Tokens

```shell
terraform plan -var cluster_name=${CLUSTER_NAME} -var vmw_host=${HOST} -var vmw_api_token=${API_TOKEN}
```

5. Apply changes while skipping interactive approval

#### **Note:** _This Terraform script performs the following actions:_
* Creates a resource group in Azure.
* Update user assigned identity.
* Creates an AKS Cluster
* Generates a Kubeconfig YAML
* Attaches the AKS cluster to Tanzu Mission Control

```shell
terraform apply --auto-approve -var cluster_name=${CLUSTER_NAME} -var vmw_host=${HOST} -var vmw_api_token=${API_TOKEN}
```

6. Detach the AKS cluster from TMC, and delete the AKS Cluster
```shell
terraform destroy --auto-approve -var cluster_name=${CLUSTER_NAME} -var vmw_host=${HOST} -var vmw_api_token=${API_TOKEN}
```
