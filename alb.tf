# Create a application load balancer for etcd
resource "aws_lb" "alb" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.etcd.id]
  subnets            = local.subnet_ids_list
  internal           = false
}

# Create the target group for the ALB
resource "aws_lb_target_group" "group" {
  name     = "${var.cluster_name}-target-group"
  port     = "2379"
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/version"
    port                = "2379"
  }
}

# Create a listener on the default ETCD listener port
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "2379"
  protocol          = "HTTP"

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