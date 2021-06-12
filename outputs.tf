output "ip" {
  value = aws_instance.app.public_ip
}

output "dns_name" {
  value = aws_instance.app.public_dns
}
