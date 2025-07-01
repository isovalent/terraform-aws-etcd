resource "random_string" "random_prefix" {
  length  = 5
  special = false
  upper   = false
}

# Create a network load balancer for etcd
resource "aws_lb" "nlb" {
  name               = "${random_string.random_prefix.result}-nlb"
  load_balancer_type = "network"
  security_groups    = [aws_security_group.etcd.id]
  subnets            = local.subnet_ids_list
  internal           = true
}

# Create the target group for the NLB
resource "aws_lb_target_group" "group" {
  name     = "${random_string.random_prefix.result}-nlb"
  port     = "2379"
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/readyz"
    port                = "2379"
  }
}

# Create a listener on the default ETCD listener port
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "2379"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.group.arn
    type             = "forward"
  }
}

# Target our EC2s
resource "aws_lb_target_group_attachment" "etcds" {
  count            = var.node_count
  target_group_arn = aws_lb_target_group.group.arn
  target_id        = aws_instance.etcds[count.index].id
  port             = 2379
}
