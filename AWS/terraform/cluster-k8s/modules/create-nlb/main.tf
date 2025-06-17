resource "aws_security_group" "k8s_endpoint_sg" {
  name        = "k8s-endpoint-sg"
  description = "Allow access to Kubernetes API endpoint"
  vpc_id      = var.vpc_id

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = "k8s"
    type    = "endpoint"
  }
}

resource "aws_lb" "nlb" {
    name               = "k8s-nlb"
    internal           = false
    load_balancer_type = "network"
    subnets            = [var.subnet_id]
    enable_deletion_protection = true
    ip_address_type    = "ipv4"
    security_groups    = [aws_security_group.k8s_endpoint_sg.id]
    tags = {
        project = "k8s"
        type    = "endpoint"
    }
}

resource "aws_lb_target_group" "nlb_tg" {
  name     = "k8s-nlb-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id
}


resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}
