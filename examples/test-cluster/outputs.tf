output "nodes" {
  value       = module.test_cluster.nodes.*
  description = "ID, public and private IP address, and subnet ID of all nodes of the created cluster."
}

output "etcd-endpoint" {
  value       = module.test_cluster.etcd-endpoint
  description = "etcd load balancer endpoint"
}