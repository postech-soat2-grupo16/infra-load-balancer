provider "aws" {
  region = var.aws_region
}

#Configuração do Terraform State
terraform {
  backend "s3" {
    bucket = "terraform-state-soat"
    key    = "infra-load-balancer/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-state-soat-locking"
    encrypt        = true
  }
}

### Target Group + Load Balancer

resource "aws_lb_target_group" "target_group_soat_api" {
  name        = "tg-soat-api"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    matcher             = "200-299"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    infra = "tg-soat-api"
  }
}

output "target_group_soat_api_arn" {
  value = aws_lb_target_group.target_group_soat_api.arn
}

resource "aws_lb" "alb_soat_api" {
  depends_on = [ aws_lb_target_group.target_group_soat_api ]
  name               = "alb-soat-api"
  internal           = true
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  security_groups = [var.sg_load_balancer]
  subnets = [
    var.subnet_a,
    var.subnet_b
  ]

  tags = {
    infra = "alb-soat-api"
  }
}

resource "aws_lb_listener" "alb_soat_listener" {
  depends_on        = [aws_lb.alb_soat_api]
  load_balancer_arn = aws_lb.alb_soat_api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_soat_api.arn
  }

  tags = {
    Name  = "alb-soat-listener"
    infra = "alb-soat-listener"
  }

}