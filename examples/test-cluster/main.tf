locals {
  cluster_name    = "test-cluster"
  region          = "us-west-1"
  domain_name     = "hartetcd1.com"
  tags = {
    "usage" = "dogfooding",
    "owner" = "isovalent",
  }
}

provider "aws" {
  alias   = "us_west_1"
  profile = "cilium-dev"
  region  = "us-west-1"
}

provider "github" {
  owner = "isovalent"
  token = var.github_token
}

module "test_vpc" {
  source = "git::ssh://git@github.com/isovalent/terraform-aws-vpc.git?ref=1.1"
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
  vpc_id = module.test_vpc.id
  cluster_name   = local.cluster_name
  region = local.region
  tags   = local.tags
  node_count = 3
  domain_name = local.domain_name
}