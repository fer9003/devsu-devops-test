variable "public_ip_admin" {
    description = "IP public"
    type = list(string)
}

variable "ports" {
    type = list(number)
}
variable "project" {type = string}

variable "node_private_ip" {}

variable "aws_vpc_id" {}
variable "aws_subnet_id" {}
variable "node_instance_type"{}
variable "key_name" {}