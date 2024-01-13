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

# # Listener Mock 200 OK
# resource "aws_lb_target_group" "teste_tg_1" {
#   name     = "teste-tg1"
#   port     = 8000
#   protocol = "HTTP"
#   vpc_id   = var.vpc_id
# }

# resource "aws_lb_listener" "alb_listener_fastfood_mock" {
#   load_balancer_arn = aws_lb.alb_fastfood_api.arn
#   port              = 8000
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       status_code  = "200"
#       message_body = "OK"
#     }
#   }
# }

# resource "aws_lb_listener_rule" "app1_rule" {
#   listener_arn = aws_lb_listener.alb_listener_fastfood_mock.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.teste_tg_1.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/app1/*"]
#     }
#   }
# }

### Target Group + Load Balancer

# resource "aws_lb_target_group" "tg_fastfood_api" {
#   name        = "target-group-fastfood"
#   port        = 8000
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = var.vpc_id

#   health_check {
#     enabled             = true
#     interval            = 30
#     matcher             = "200-299"
#     path                = "/ping"
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     timeout             = 5
#     healthy_threshold   = 5
#     unhealthy_threshold = 2
#   }

#   tags = {
#     infra   = "target-group-fastfood"
#     service = "fastfood"
#   }
# }

# output "tg_fastfood_api_arn" {
#   value = aws_lb_target_group.tg_fastfood_api.arn
# }

# resource "aws_lb_listener" "alb_fastfood_listener" {
#   depends_on        = [aws_lb.alb_fastfood_api]
#   load_balancer_arn = aws_lb.alb_fastfood_api.arn
#   port              = 8000
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg_fastfood_api.arn
#   }

#   tags = {
#     Name    = "alb-listener-fastfood"
#     infra   = "alb-listener-fastfood"
#     service = "fastfood"
#   }
# }
