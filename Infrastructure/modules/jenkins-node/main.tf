provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "sg_jenkins_node" {
    vpc_id = var.aws_vpc_id

    dynamic ingress {
        iterator = port
        for_each = var.ports
            content {
                from_port = port.value
                to_port = port.value
                protocol = "tcp"
                cidr_blocks = var.public_ip_admin
            }
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sg-node-${var.project}"
    }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins_node" {
    ami             = data.aws_ami.ubuntu.id
    subnet_id       = var.aws_subnet_id
    instance_type   = var.node_instance_type
    private_ip      = var.node_private_ip 
    vpc_security_group_ids = [aws_security_group.sg_jenkins_node.id]
    associate_public_ip_address = true
    key_name = var.key_name

    root_block_device {
        delete_on_termination = true
        throughput            = 0
        volume_size           = 8
        volume_type           = "gp2"
    }
    tags = {
        Name = "jenkins-node-${var.project}"
    }
}

resource "aws_eip" "jenkins_node_public_ip" {
    instance    = aws_instance.jenkins_node.id
    vpc         = true
    tags = {
        Name = "publicIP-Jenkins-node-${var.project}"
    }
}

