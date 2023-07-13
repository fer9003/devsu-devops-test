variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "project" {
  type    = string
  default = "infra-ops"
}

variable "public_ip_admin" {
  description = "IP public admin"
  type = list(string)
}

variable "ports" {
    type = list(number)
}

variable "path_key_name" {
  type = string
}

variable "private_ip" {
}

variable "instance_type"{}
variable "key_name" {}

variable "vpc_cidr_block" {
  type = string
  default = "172.23.0.0/24"
}
variable "subnet_cidr_block_1" {
  type = string
  default = "172.23.0.0/27"
}
variable "az_1" {
  type = string
  default = "us-east-2a"
}

variable "node_private_ip" {}
variable "node_instance_type"{}