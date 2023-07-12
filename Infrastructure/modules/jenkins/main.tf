provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "sg_jenkins" {
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
        Name = "sg-${var.project}"
    }
}

data "aws_ami" "amzlinux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
} 

resource "aws_instance" "jenkins_server" {
    ami             = data.aws_ami.amzlinux2.id
    subnet_id       = var.aws_subnet_id
    instance_type   = var.instance_type
    private_ip      = var.private_ip 
    vpc_security_group_ids = [aws_security_group.sg_jenkins.id]
    associate_public_ip_address = true
    key_name = var.key_name

    root_block_device {
        delete_on_termination = true
        throughput            = 0
        volume_size           = 16
        volume_type           = "gp2"
    }
    tags = {
        Name = "jenkins-${var.project}"
    }
}

resource "aws_eip" "jenkins_public_ip" {
    instance    = aws_instance.jenkins_server.id
    vpc         = true
    tags = {
        Name = "publicIP-Jenkins-${var.project}"
    }
}


resource "null_resource" "configure_server" {
  triggers = {
    trigger = aws_eip.jenkins_public_ip.public_ip
  }
  provisioner "local-exec" {
    working_dir = "${path.module}/ansible"
    command     = "ansible-playbook --inventory ${aws_eip.jenkins_public_ip.public_ip}, --private-key ${var.path_key_name} --user ec2-user playbook.yaml"
  }
} 
