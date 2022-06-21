output "nodes" {
  value = [
    for i in aws_instance.etcds : {
      id         = i.id
      subnet_id  = i.subnet_id
      private_ip = i.private_ip
      public_ip  = i.public_ip
    }
  ]
  description = "ID, public and private IP address, and subnet ID of all nodes of the created cluster."
}

output "etcd-endpoint" {
  value = "http://etcd.${var.cluster_name}.${var.domain_name}:2379"
  description = "ALB endpoint"
}