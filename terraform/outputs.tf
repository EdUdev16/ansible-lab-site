output "public_ip" {
  value = aws_instance.site.public_ip
}

output "site_url" {
  value = "http://${aws_instance.site.public_ip}/"
}
