## terraform-aws-etcd

Deploys an etcd cluster in AWS on Amazon Linux 2. Outputs node information and LB endpoint. Meant to be used as a module.

Look at `examples/test-cluster` for an example on how to use this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.etcds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.listener_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.etcds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.etcd-lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.etcds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.etcd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_security_group.etcd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.etcd-from-vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_id.index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_string.random_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_architecture"></a> [ami\_architecture](#input\_ami\_architecture) | The architecture of the AMI to use for the etcd cluster. | `string` | `"x86_64"` | no |
| <a name="input_ami_name_filter"></a> [ami\_name\_filter](#input\_ami\_name\_filter) | The name of the AMI to use for the etcd cluster. | `string` | `"amzn2-ami-hvm*"` | no |
| <a name="input_ami_owner_id"></a> [ami\_owner\_id](#input\_ami\_owner\_id) | The AMI ID to use for the etcd cluster. | `string` | `"amazon"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the etcd cluster. | `string` | n/a | yes |
| <a name="input_disk_iops"></a> [disk\_iops](#input\_disk\_iops) | IOPS of the EBS volume (e.g. 3000) | `number` | `3000` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of the EBS volume in GB | `number` | `30` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Type of the EBS volume (e.g. standard, gp2, gp3, io1) | `string` | `"gp3"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain to use for etcd DNS. | `string` | `"etcd.local"` | no |
| <a name="input_etcd_version"></a> [etcd\_version](#input\_etcd\_version) | The version of etcd you are deploying | `string` | `"v3.6.1"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 Instance Type | `string` | `"t3.small"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | The number of nodes in the cluster. | `number` | `3` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which to create the cluster. | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The set of tags to place on the cluster. | `map(string)` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR block for access to/from etcd | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which to create the etcd cluster. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_etcd-endpoint"></a> [etcd-endpoint](#output\_etcd-endpoint) | ALB endpoint |
| <a name="output_etcd_security_group_id"></a> [etcd\_security\_group\_id](#output\_etcd\_security\_group\_id) | The security group for etcd nodes |
| <a name="output_nodes"></a> [nodes](#output\_nodes) | ID, public and private IP address, and subnet ID of all nodes of the created cluster. |
<!-- END_TF_DOCS -->