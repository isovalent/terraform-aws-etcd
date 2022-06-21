data "aws_ami" "flatcar_stable_latest" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Flatcar-stable-*"]
  }
}

// Used to list all public subnets in the VPC.
data "aws_subnets" "public" {
  filter {
    name = "vpc-id"
    values = [
      var.vpc_id
    ]
  }
  filter {
    name = "tag:type"
    values = [
      "public"
    ]
  }
}

data "aws_subnets" "private" {
  filter {
    name = "vpc-id"
    values = [
      var.vpc_id
    ]
  }
  filter {
    name = "tag:type"
    values = [
      "private"
    ]
  }
}

// Used to pick a subnet for nodes
resource "random_id" "index" {
  byte_length = 1
}

locals {
  subnet_ids_list         = tolist(data.aws_subnets.public.ids)                       // used for a random subnet
  subnet_ids_random_index = random_id.index.dec % length(data.aws_subnets.public.ids) // used for a random subnet
  instance_subnet_id      = local.subnet_ids_list[local.subnet_ids_random_index]      // used for a random subnet
}

// Create etcd instances
resource "aws_instance" "etcds" {
  count         = var.node_count
  ami           = data.aws_ami.flatcar_stable_latest.image_id
  instance_type = var.instance_type
  user_data     = data.ct_config.etcd-ignitions.*.rendered[count.index]

  # storage
  root_block_device {
    volume_type = var.disk_type
    volume_size = var.disk_size
    iops        = var.disk_iops
    encrypted   = true
  }

  #network
  vpc_security_group_ids = [
    aws_security_group.etcd.id
  ]
  associate_public_ip_address = true
  subnet_id                   = local.instance_subnet_id

  lifecycle {
    ignore_changes = [
      subnet_id,
      ami,
      user_data,
    ]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${count.index}"
  })
}

# etcd Ignition configs
data "ct_config" "etcd-ignitions" {
  count    = var.node_count
  content  = data.template_file.etcd-configs.*.rendered[count.index]
  strict   = true
  snippets = var.etcd_snippets
}

# render the etcd Container Linux configs
data "template_file" "etcd-configs" {
  count = var.node_count

  template = file("${path.module}/etcd.yaml")

  vars = {
    # Cannot use cyclic dependencies on controllers or their DNS records
    etcd_name            = "etcd${count.index}"
    etcd_domain          = "${var.cluster_name}-etcd${count.index}.${var.domain_name}"
    etcd_initial_cluster = join(",", data.template_file.etcd-cluster.*.rendered)
    ssh_authorized_key   = tls_private_key.ssh_key.public_key_openssh
    etcd_peer_url        = "http://${var.cluster_name}-etcd${count.index}.${var.domain_name}:2380"
  }
}

data "template_file" "etcd-cluster" {
  count    = var.node_count
  template = "etcd$${index}=http://$${cluster_name}-etcd$${index}.$${domain_name}:2380"

  vars = {
    index        = count.index
    cluster_name = var.cluster_name
    domain_name  = var.domain_name
  }
}