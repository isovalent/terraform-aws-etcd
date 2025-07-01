locals {
  cluster_name = "test-cluster"
  region       = "us-west-1"
  domain_name  = "hartetcd1.com"
  tags = {
    "usage" = "dogfooding",
    "owner" = "isovalent",
  }
}

provider "aws" {
  alias  = "us_west_1"
  region = "us-west-1"
}

module "test_vpc" {
  source = "git::ssh://git@github.com/isovalent/terraform-aws-vpc.git?ref=v1.13"
  providers = {
    aws = aws.us_west_1
  }
  cidr   = "10.3.0.0/16"
  name   = local.cluster_name
  region = local.region
  tags   = local.tags
}

module "test_cluster" {
  source = "../../"

  providers = {
    aws = aws.us_west_1
  }
  vpc_id       = module.test_vpc.id
  cluster_name = local.cluster_name
  region       = local.region
  tags         = local.tags
  node_count   = 3
  domain_name  = local.domain_name
  vpc_cidr     = module.test_vpc.vpc_cidr_block
}

output "nodes" {
  value       = module.test_cluster.nodes.*
  description = "ID, public and private IP address, and subnet ID of all nodes of the created cluster."
}

output "etcd-endpoint" {
  value       = module.test_cluster.etcd-endpoint
  description = "etcd load balancer endpoint"
}