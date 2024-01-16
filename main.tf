provider "aws" {
  region = var.aws_region
}

#Configuração do Terraform State
terraform {
  backend "s3" {
    bucket = "terraform-state-soat"
    key    = "load-balancer-fastfood/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-state-soat-locking"
    encrypt        = true
  }
}

#Security Group LB
resource "aws_security_group" "sg_load_balancer_fastfood" {
  name_prefix = "security-group-lb-fastfood"
  description = "SG Load Balancer - fastfood"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    infra   = "load-balancer-fastfood"
    service = "fastfood"
    Name    = "load-balancer-fastfood"
  }
}

output "sg_load_balancer_fastfood_id" {
  value = aws_security_group.sg_load_balancer_fastfood.id
}

# ALB
resource "aws_lb" "alb_fastfood_api" {
  depends_on         = [aws_security_group.sg_load_balancer_fastfood]
  name               = "alb-fastfood"
  internal           = true
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  security_groups = [aws_security_group.sg_load_balancer_fastfood.id]
  subnets = [
    var.subnet_a,
    var.subnet_b
  ]

  tags = {
    infra   = "alb-fastfood"
    service = "fastfood"
  }
}

# Listener empty/default

resource "aws_lb_listener" "alb_fastfood_listener" {
  load_balancer_arn = aws_lb.alb_fastfood_api.arn
  port              = 8000
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }

  tags = {
    Name    = "listener-default"
    infra   = "alb-fastfood"
    service = "fastfood"
  }
}
