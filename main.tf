locals {
  fqdn = var.parent_domain_name == null ? aws_instance.app.public_dns : "${var.hostname}.${var.parent_domain_name}"
  tag = var.environment == "production" ? var.hostname : "${var.hostname}-${var.environment}"
}

resource "aws_key_pair" "app" {
  key_name   = local.tag
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
    Name = local.tag
  }
}

resource "aws_ebs_volume" "app" {
  size              = var.managed_disk_gbs
  availability_zone = var.availability_zone

  tags = {
    Name = local.tag
  }
}

resource "aws_volume_attachment" "app" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.app.id
  instance_id = aws_instance.app.id
}

data "aws_route53_zone" "dns_zone" {
  count = var.parent_domain_name == null ? 0 : 1
  name         = "${var.parent_domain_name}."
}

resource "aws_route53_record" "this" {
  count = var.parent_domain_name == null ? 0 : 1
  zone_id = data.aws_route53_zone.dns_zone[0].zone_id
  name    = local.fqdn
  type    = "A"
  ttl     = "300"
  records = [aws_instance.app.public_ip]

  provisioner "local-exec" {
    when    = "create"
    command = "ssh-keyscan -t rsa ${self.name} >> ${pathexpand("~/.ssh/known_hosts")}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "ssh-keygen -R ${self.name}"
  }
}
