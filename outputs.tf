output "nodes" {
  value = [
    for index, i in aws_instance.etcds : {
      id         = i.id
      subnet_id  = i.subnet_id
      private_ip = i.private_ip
      public_ip  = i.public_ip
      url        = "http://${var.cluster_name}-etcd${index}.${var.domain_name}:2379"
    }
  ]
  description = "ID, public and private IP address, and subnet ID of all nodes of the created cluster."
}

output "etcd-endpoint" {
  value       = "http://etcd.${var.cluster_name}.${var.domain_name}:2379"
  description = "ALB endpoint"
}

output "etcd_security_group_id" {
  value       = aws_security_group.etcd.id
  description = "The security group for etcd nodes"
}