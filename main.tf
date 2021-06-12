locals {
  name = var.environment == "production" ? var.app_name : "${var.app_name}-${var.environment}"
}

resource "aws_key_pair" "app" {
  key_name   = local.name
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "app" {
  ami           = var.ami_id
  availability_zone = var.availability_zone
  instance_type = var.instance_size
  key_name = aws_key_pair.app.key_name
  associate_public_ip_address  = true
  security_groups = [ var.security_group_name ]

  root_block_device {
    volume_size = var.root_disk_gbs
  }

  tags = {
    Name = local.name
  }
}

resource "aws_ebs_volume" "app" {
  size              = var.managed_disk_gbs
  availability_zone = var.availability_zone

  tags = {
    Name = local.name
  }
}

resource "aws_volume_attachment" "app" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.app.id
  instance_id = aws_instance.app.id
}
