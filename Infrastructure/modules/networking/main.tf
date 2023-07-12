provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "vpc_infra_ops" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "vpc-${var.project}"
    }
}

resource "aws_subnet" "subnet_infra_ops_1" {
    vpc_id = aws_vpc.vpc_infra_ops.id
    cidr_block = var.subnet_cidr_block_1
    availability_zone = var.az_1
    tags = {
        Name = "subnet-${var.project}"
    }
}

resource "aws_internet_gateway" "igw_infra_ops" {
    vpc_id = aws_vpc.vpc_infra_ops.id
    tags = {
        Name = "igw${var.project}"
    }
}

resource "aws_route_table" "rtb_infra_ops" {
    vpc_id = aws_vpc.vpc_infra_ops.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_infra_ops.id
    }
    tags = {
        Name = "rtb-${var.project}"
    }
}

resource "aws_route_table_association" "rtb_subnet_ops_1" {
    subnet_id = aws_subnet.subnet_infra_ops_1.id
    route_table_id = aws_route_table.rtb_infra_ops.id
}
