resource "tls_private_key" "ssh_key_etcd" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_key_pair" "ssh_access_etcd" {
  key_name   = "Generated key for ETCD ${var.cluster_name}"
  public_key = tls_private_key.ssh_key_etcd.public_key_openssh
}

data "aws_ami" "main" {
  most_recent = true
  owners = [
    var.ami_owner_id
  ]

  filter {
    name = "name"
    values = [
      var.ami_name_filter,
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = [
      var.ami_architecture
    ]
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
  subnet_ids_list = tolist(data.aws_subnets.public.ids) // used to distrubute nodes in subnets
}

// Create etcd instances
resource "aws_instance" "etcds" {
  count         = var.node_count
  ami           = data.aws_ami.main.id
  instance_type = var.instance_type
  user_data = templatefile("${path.module}/etcd.sh.tpl", {
    etcd_name            = "etcd${count.index}",
    etcd_domain          = "${var.cluster_name}-etcd${count.index}.${var.domain_name}",
    etcd_initial_cluster = join(",", [for i in range(var.node_count) : "etcd${i}=http://${var.cluster_name}-etcd${i}.${var.domain_name}:2380"]),
    ssh_authorized_key   = tls_private_key.ssh_key_etcd.public_key_openssh,
    etcd_peer_url        = "http://${var.cluster_name}-etcd${count.index}.${var.domain_name}:2380"
  })

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
  subnet_id                   = element(local.subnet_ids_list, count.index)

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