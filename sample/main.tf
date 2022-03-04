terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ca-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  name = "vm-sample"
}

module "security_group" {
  source = "git@github.com:rmtly/aws-module-security-group.git?ref=v1.0"

  name = local.name
  ingress_rules = [
    {
      "name": "TLS",
      "port": 443
    },
    {
      "name": "SSH",
      "port": 22
    }
  ]
  tags = {
    name = local.name
    environment = "dev"
  }
}

module "vm" {
  source = "../."

  environment = "dev"
  parent_domain_name = "rmtly.com"
  hostname = local.name
  ami_id = data.aws_ami.ubuntu.id
  instance_size = "t3.nano"
  managed_disk_gbs = 10
  ssh_public_key_path = "config/dev/id_rsa_app.pub"
  security_group_name = local.name
}
