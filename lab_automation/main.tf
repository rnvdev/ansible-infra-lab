terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
    external = {
      source = "hashicorp/external"
      version = "2.2.3"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "x"
  secret_key = "x"
}


# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# INTERNET-GATEWAY:
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.main.id
}


# ROUTE-TABLE (PUBLIC)
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

}

#ROUTE-RABLE-ASSOCIATION:
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.example.id
}


# SUBNET:
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# GENERATE KEY.PEM
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# SET KEY ON AWS AND CREATE A KEY.PEM FILE IN YOUR CURRENT DIRECTORY:
resource "aws_key_pair" "kp" {
  key_name   = "myKey"       
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

# GET OUR IP:
data "external" "myipaddr" {
    program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

#SECURITY GROUP
resource "aws_security_group" "ssh-rule" {
  name        = "allow_SSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${data.external.myipaddr.result.ip}/32"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "automation-script"
  }
}

# ECSs
resource "aws_instance" "ec2" {
  ami                     = "ami-00874d747dde814fa"
  instance_type           = "t3.medium"
  count                   = 1
  key_name                = aws_key_pair.kp.key_name
  vpc_security_group_ids  = [aws_security_group.ssh-rule.id]
  disable_api_termination = false
  subnet_id               = aws_subnet.main.id
 
  
  tags = {
    Name = "Server ${count.index}"
  }
}
