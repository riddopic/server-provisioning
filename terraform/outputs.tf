output "vpc_id" {
  value = "${aws_vpc.chef-provisioned-vpc.id}"
}
output "us-west-2b-public" {
  value = "${aws_subnet.us-west-2b-public.id}"
}
# output "us-west-2c-public" {
#   value = "${aws_subnet.us-west-2c-public.id}"
# }
# output "us-west-2b-private" {
#   value = "${aws_subnet.us-west-2b-private.id}"
# }
# output "us-west-2c-private" {
#   value = "${aws_subnet.us-west-2c-private.id}"
# }
output "chef-server_security_group_id" {
  value = "${aws_security_group.chef-server.id}"
}
output "chef-analytics_security_group_id" {
  value = "${aws_security_group.chef-analytics.id}"
}
output "chef-supermarket_security_group_id" {
  value = "${aws_security_group.chef-supermarket.id}"
}
output "chef-compliance_security_group_id" {
  value = "${aws_security_group.chef-compliance.id}"
}
output "chef-compliance_security_group_id" {
  value = "${aws_security_group.chef-compliance.id}"
}
output "jenkins-worker_security_group_id" {
  value = "${aws_security_group.jenkins-worker.id}"
}
