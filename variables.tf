variable "cluster_name" {
  description = "The name of the etcd cluster."
  type        = string
}

variable "region" {
  description = "The region in which to create the cluster."
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "The domain to use for etcd DNS."
  type        = string
  default     = "etcd.local"
}

variable "node_count" {
  description = "The number of nodes in the cluster."
  type        = number
  default     = 3
}

variable "tags" {
  description = "The set of tags to place on the cluster."
  type        = map(string)
}

variable "vpc_id" {
  description = "The ID of the VPC in which to create the etcd cluster."
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.small"
}

variable "disk_size" {
  type        = number
  description = "Size of the EBS volume in GB"
  default     = 30
}

variable "disk_type" {
  type        = string
  description = "Type of the EBS volume (e.g. standard, gp2, gp3, io1)"
  default     = "gp3"
}

variable "disk_iops" {
  type        = number
  description = "IOPS of the EBS volume (e.g. 3000)"
  default     = 3000
}

variable "etcd_snippets" {
  type        = list(string)
  description = "Etcd Container Linux Config snippets"
  default     = []
}