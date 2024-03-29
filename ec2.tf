resource "tls_private_key" "ssh_key_etcd" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "ssh_access_etcd" {
  key_name   = "Generated key for ETCD ${var.cluster_name}"
  public_key = tls_private_key.ssh_key_etcd.public_key_openssh
}

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
  count = var.node_count
  content = <<EOF
${templatefile("${abspath(path.module)}/etcd.yaml", {
  etcd_name            = "etcd${count.index}"
  etcd_domain          = "${var.cluster_name}-etcd${count.index}.${var.domain_name}"
  etcd_initial_cluster = <<EOL
%{for index in range(var.node_count)}etcd${index}=http://${var.cluster_name}-etcd${index}.${var.domain_name}:2380%{if index != (var.node_count - 1)},%{endif}%{endfor}
EOL
  ssh_authorized_key   = tls_private_key.ssh_key_etcd.public_key_openssh
  etcd_peer_url        = "http://${var.cluster_name}-etcd${count.index}.${var.domain_name}:2380"
})}
  EOF
strict   = true
snippets = var.etcd_snippets
}