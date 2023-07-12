terraform {
  required_version = "~> 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70"
    }
  }

  backend "s3" {
    bucket         = "infrastructure-fm90"
    key            = "infra/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "infrastructure-fm"
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"
  aws_region = var.aws_region
  project = var.project
  vpc_cidr_block = var.vpc_cidr_block
  subnet_cidr_block_1 = var.subnet_cidr_block_1
  az_1 = var.az_1
}

module "jenkins" {
  source        = "./modules/jenkins"
  aws_vpc_id    = module.networking.aws_vpc_id_out.id
  aws_subnet_id = module.networking.aws_subnet_id_out.id
  public_ip_admin = var.public_ip_admin
  project = var.project
  ports = var.ports
  path_key_name = var.path_key_name
  private_ip = var.private_ip
  instance_type = var.instance_type
  key_name = var.key_name
}
