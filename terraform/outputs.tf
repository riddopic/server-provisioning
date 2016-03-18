
output "F5 HTTP URL:" {
  value = "https://${aws_instance.f5-bigip.public_dns}"
}

output "F5 SSH Address:" {
  value = "ssh admin@${aws_instance.f5-bigip.public_dns}"
}

output "SSH Bastion Host:" {
  value = "${aws_instance.chef-provisioned-bastion.public_dns}"
}
