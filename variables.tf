variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_az_a" {
  type    = string
  default = "us-east-1a"
}

variable "aws_az_b" {
  type    = string
  default = "us-east-1b"
}

variable "vpc_id" {
  type    = string
  default = "value"
}

variable "subnet_a" {
  type    = string
  default = "value"
}

variable "subnet_b" {
  type    = string
  default = "value"
}

variable "sg_load_balancer" {
  type    = string
  default = "value"
}

variable "health_check_path" {
  type = string
  default = "/ping"
}