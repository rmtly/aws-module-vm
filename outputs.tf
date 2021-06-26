output "ip" {
  value = aws_instance.app.public_ip
}

output "dns_name" {
  value = local.fqdn
}
