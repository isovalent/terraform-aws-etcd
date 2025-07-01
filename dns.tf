resource "aws_route53_zone" "etcd" {
  name = var.domain_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "etcds" {
  count   = var.node_count
  zone_id = aws_route53_zone.etcd.id
  name    = format("%s-etcd%d.%s.", var.cluster_name, count.index, var.domain_name)
  type    = "A"
  ttl     = "30"
  records = [aws_instance.etcds.*.private_ip[count.index]]
}

resource "aws_route53_record" "etcd-lb" {
  zone_id = aws_route53_zone.etcd.id
  name    = "etcd.${var.cluster_name}.${var.domain_name}"
  type    = "CNAME"
  ttl     = "30"
  records = [aws_lb.nlb.dns_name]
}