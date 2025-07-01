// Create Security Group
resource "aws_security_group" "etcd" {
  vpc_id = var.vpc_id
  name   = "etcd"
}

resource "aws_vpc_security_group_ingress_rule" "etcd-from-vpc" {
  security_group_id = aws_security_group.etcd.id
  from_port         = 2379
  ip_protocol       = "tcp"
  to_port           = 2380
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.etcd.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}