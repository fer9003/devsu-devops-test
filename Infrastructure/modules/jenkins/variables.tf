variable "public_ip_admin" {
    description = "IP public admin"
    type = list(string)
}

variable "ports" {
    type = list(number)
}
variable "project" {type = string}
variable "path_key_name" {type = string}
variable "private_ip" {}
variable "aws_vpc_id" {}
variable "aws_subnet_id" {}
variable "instance_type"{}
variable "key_name" {}

