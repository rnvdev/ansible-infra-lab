terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.2.3"
    }
  }
}

provider "aws" {
  region     = var.aws_region
}

module "vpc" {
  source     = "./vpc"
  cidr_block = "10.0.0.0/16"
  name       = "automation-lab"
}

module "igw" {
  source = "./igw"

  vpc_id = module.vpc.id
  name   = "automation-lab"
}

module "rt-public" {
  source = "./rt"
  vpc_id = module.vpc.id
  name   = "automation-lab"

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.igw.id
  }
}

module "subnet" {
  source            = "./subnet"
  vpc_id            = module.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone
  name              = "automation-lab"
}

module "rt-association" {
  source         = "./rt-association"
  subnet_id      = module.subnet.id
  route_table_id = module.rt-public.id
}



resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"
  public_key = tls_private_key.pk.public_key_openssh
}

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

resource "aws_security_group" "ssh-rule" {
  name        = "allow_SSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.id

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
    "Name" = "automation-lab"
  }
}

resource "aws_instance" "ec2" {
  ami                     = var.ec2_ami_id
  instance_type           = var.ec2_instance_type
  count                   = 3
  key_name                = aws_key_pair.kp.key_name
  vpc_security_group_ids  = [aws_security_group.ssh-rule.id]
  disable_api_termination = false
  subnet_id               = module.subnet.id
  availability_zone       = var.availability_zone

  user_data = element([
    "${file("./scripts/installs_machine_00.sh")}",
    "${file("./scripts/installs_machine_01.sh")}",
    "${file("./scripts/installs_machine_02.sh")}"
  ], count.index)

  tags = {
    "Name" = element([
      "ansible-01",
      "webserver-01", 
      "webserver-02"
    ],count.index)
 }
}

resource "aws_eip" "ec2-eips" {
  count    = length(aws_instance.ec2)
  instance = aws_instance.ec2[count.index].id
  vpc      = true
}

output "private_key_pem" {
  description = "Private key for SSH access to EC2 instances. Save this securely if needed."
  value       = tls_private_key.pk.private_key_pem
  sensitive   = true
}
