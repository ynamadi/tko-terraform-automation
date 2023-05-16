# Create a Tanzu Mission Control AWS EKS cluster entry
resource "tanzu-mission-control_ekscluster" "tf_eks_cluster" {
  credential_name = var.tmc_credential_name
  region          = var.region
  name            = var.cluster_name

  ready_wait_timeout = "30m"

  meta {
    description = "EKS Cluster via TMC"
    labels      = { "bu" : "enterprise-bu" }
  }

  spec {
    cluster_group = "default"

    config {
      role_arn = var.aws_control_plane_arn

      kubernetes_version = "1.24"
      tags               = { "testEnv" : "true" }

      kubernetes_network_config {
        service_cidr = var.service_cidr
      }

      logging {
        api_server         = false
        audit              = true
        authenticator      = true
        controller_manager = false
        scheduler          = true
      }

      vpc {
        enable_private_access = false
        enable_public_access  = true
        public_access_cidrs = var.public_access_cidrs
        security_groups = var.security_groups
        subnet_ids = var.subnet_ids
      }
    }

    nodepool {
      info {
        name        = "second-np"
        description = "tf nodepool description"
      }

      spec {
        role_arn       = var.aws_worker_arn
        ami_type       = "AL2_x86_64"
        capacity_type  = "ON_DEMAND"
        root_disk_size = 40
        tags           = { "clusterType" : "test" }
        node_labels    = { "nodeType" : "linux" }

        subnet_ids = var.subnet_ids

        scaling_config {
          desired_size = 3
          max_size     = 5
          min_size     = 1
        }

        update_config {
          max_unavailable_nodes = "4"
        }

        instance_types = [
          "t3.medium",
          "m3.large"
        ]

      }
    }
  }
}