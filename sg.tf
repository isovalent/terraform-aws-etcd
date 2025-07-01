// Create Security Group
resource "aws_security_group" "etcd" {
  vpc_id = var.vpc_id
  name   = "etcd"

  ingress {
    description = "Allow client and peer inbound"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = var.allow_cidr_blocks_ingress
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}