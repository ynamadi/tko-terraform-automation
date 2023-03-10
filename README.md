# Attaching an AKS Cluster to Tanzu Mission Control, and Onboarding the cluster to Tanzu Service Mesh

This script leverages azurerm terraform provider to provision an AKS Cluster, TMC terraform provider to attach the cluster to Tanzu Mission Control and http provider to onboard the cluster to Tanzu Service Mesh via the TSM API.

#### **Note:** _This Terraform script performs the following actions:_
* Creates a resource group in Azure.
* Update user assigned identity.
* Creates an AKS Cluster
* Generates a Kubeconfig YAML
* Attaches the AKS cluster to Tanzu Mission Control
* Onboards cluster to TSM via the TSM API


### Prerequisites
1. Azure Account Access [Start Free]("https://azure.microsoft.com/en-us/free/")
2. Azure Cli [Install Azure Cli]("https://learn.microsoft.com/en-us/cli/azure/install-azure-cli")
3. Terraform Cli [Install Terraform]("https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli")
4. Access to VMWare Cloud Services (with access to Tanzu Mission Control and Tanzu Service Mesh tenant) [Login]("https://console.cloud.vmware.com/")
5. Generate Token via VMWare Cloud Services with service role access to Tanzu Mission Control and Tanzu Service Mesh.
   1. Login to VMWare Cloud Services.
   2. On the top right click user/organization name.
   3. Click on My Account.
   4. Navigate to API Tokens.
   5. Generate token with service role access to Tanzu Mission Control and Tanzu Service Mesh.

### Provision Infrastructure, Attach to TMC & Onboard to TSM steps. 

#### Step 1: Switch to the iac/azure directory
```shell
cd iac/azure
```

#### Step 2: Update variables.tf with tmc_host, tsm_host & cluster_name (This will be unique for each organization/tenant)
```terraform
variable "tmc_host" {
  type        = string
  description = "TMC Host"
  default = "${YOUR_ORG}.tmc.cloud.vmware.com"
}
```

```terraform
variable "tsm_host" {
  type        = string
  default = "${ENV}.nsxservicemesh.vmware.com"
  description = "Host for TSM Cloud"
}
```

```terraform
variable "cluster_name" {
  type        = string
  description = "AKS Cluster Name"
  default     = "${YOUR_CLUSTER_NAME}"
}
```

#### Step 3: Creating Service Principle & Updating Variables
```shell
./config.sh
```

#### Step 4: Initializing Terraform
```shell
terraform init -upgrade
```

#### Step 5: Terraform Plan (Evaluate Resources that will be created)
```shell
terraform plan -var vmw_api_token="${CSP_TOKEN}"
```

#### Step 6: Terraform Apply (Create AKS Cluster, Attach to TMC and Onboard to TSM)
```shell
terraform apply -var vmw_api_token="${CSP_TOKEN}" --auto-approve
```

### Destroy Provisioned Infrastructure (Remove cluster from TSM & TMC, Delete Cluster)
#### Step 1: Remove Cluster from TSM & TMC and destroy resources. 
```shell
terraform destroy -var vmw_api_token="${CSP_TOKEN}" --auto-approve
```