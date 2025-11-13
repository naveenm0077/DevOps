terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}


provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "ngnix_sg" {
  name   = "nginx-sg"
  vpc_id = aws_vpc.proj_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                    = data.aws_ssm_parameter.ubuntu.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.proj_sub.id
  vpc_security_group_ids = [aws_security_group.ngnix_sg.id]

  user_data = <<EOF
  #!/bin/bash
  set -eux
  apt-get update -y
  apt-get install -y nginx
  echo "<html><h1>Hello from Terraform EC2 with nginx</h1></html>" > /var/www/html/index.html
  systemctl enable nginx
  systemctl restart nginx
  EOF

  tags = {
    Name = "tf-nginx-ec2"
  }

  depends_on = [aws_route_table_association.public_assoc]
}

resource "aws_eip" "public_ip" {
  instance = aws_instance.nginx.id
}