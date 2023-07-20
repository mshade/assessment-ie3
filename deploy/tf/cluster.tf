terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.5.2"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.10.1"
    }
  }
}

# Configure the Linode Provider
variable "linode_token" {
    type = string
}

provider "linode" {
  token = var.linode_token
}

# Create a single node cluster deploy target
resource "linode_lke_cluster" "taskly" {
    label = "taskly"
    k8s_version = "1.26"
    region = "us-east"
    tags = ["taskly"]

    pool {
        type = "g6-standard-1"
        count = 1
    }
}

# Create a sensitive output for the admin kubeconfig
output "taskly_kubeconfig" {
    value = linode_lke_cluster.taskly.kubeconfig
    sensitive = true
}

# Load the kubeconfig into a tf local to avoid having to write the file to runner disk
locals {
  kube_config = yamldecode(base64decode(linode_lke_cluster.taskly.kubeconfig))
}

provider "helm" {
  kubernetes {
    host = local.kube_config.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
    token = local.kube_config.users[0].user.token
  }
}

# Ingress controller for multi-hosting and load balancer endpoint
resource "helm_release" "ingress" {
  chart = "ingress-nginx"
  name = "ingress-nginx"
  namespace = "ingress-nginx"
  create_namespace = true
  repository = "https://kubernetes.github.io/ingress-nginx"
  version = "4.7.1"
}
