## terraform-aws-etcd

Deploys an etcd cluster in AWS on Flatcar Linux. Outputs node information and ALB endpoint. Meant to be used as a module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
| <a name="requirement_ct"></a> [ct](#requirement\_ct) | 0.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.19.0 |
| <a name="provider_ct"></a> [ct](#provider\_ct) | 0.10.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.1 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_instance.etcds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.listener_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.etcds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.etcd-lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.etcds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.etcd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_security_group.etcd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_id.index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_ami.flatcar_stable_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [ct_config.etcd-ignitions](https://registry.terraform.io/providers/poseidon/ct/0.10.0/docs/data-sources/config) | data source |
| [template_file.etcd-cluster](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.etcd-configs](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the etcd cluster. | `string` | n/a | yes |
| <a name="input_disk_iops"></a> [disk\_iops](#input\_disk\_iops) | IOPS of the EBS volume (e.g. 3000) | `number` | `3000` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of the EBS volume in GB | `number` | `30` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Type of the EBS volume (e.g. standard, gp2, gp3, io1) | `string` | `"gp3"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain to use for etcd DNS. | `string` | `"etcd.local"` | no |
| <a name="input_etcd_snippets"></a> [etcd\_snippets](#input\_etcd\_snippets) | Etcd Container Linux Config snippets | `list(string)` | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 Instance Type | `string` | `"t3.small"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | The number of nodes in the cluster. | `number` | `3` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which to create the cluster. | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The set of tags to place on the cluster. | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which to create the etcd cluster. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_etcd-endpoint"></a> [etcd-endpoint](#output\_etcd-endpoint) | ALB endpoint |
| <a name="output_nodes"></a> [nodes](#output\_nodes) | ID, public and private IP address, and subnet ID of all nodes of the created cluster. |