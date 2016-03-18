#
# Terraform
#
provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region = "${var.aws_default_region}"
}
#
# EC2 Networks
#
resource "aws_vpc" "chef-provisioned-vpc" {
  cidr_block = "${lookup(var.aws_cidrs, "chef-provisioned-vpc")}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cluster_name} VPC"
  }
}
resource "aws_internet_gateway" "chef-provisioned-gw" {
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  tags = {
    Name = "${var.cluster_name} Gateway"
  }
}
resource "aws_route53_zone" "ksplat" {
  name = "ksplat.com"
}
#
# NAT instance
#
resource "aws_security_group" "chef-provisioned-nat" {
	name = "chef-provisioned-nat"
	description = "Allow services from the private subnet through NAT"
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"

	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["${aws_subnet.us-west-2b-private.cidr_block}"]
	}

	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["${aws_subnet.us-west-2c-private.cidr_block}"]
	}

	tags {
    Name = "${var.cluster_name} NAT Security Group"
	}
}
resource "aws_instance" "chef-provisioned-nat" {
  ami = "${lookup(var.nat-amis, var.aws_default_region)}"
	availability_zone = "us-west-2b"
  instance_type = "${lookup(var.instances, "chef-provisioned-nat")}"
  count = "${lookup(var.instance_counts, "chef-provisioned-nat")}"
  key_name = "${var.aws_key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.chef-provisioned-nat.id}"]
  subnet_id = "${aws_subnet.us-west-2b-public.id}"
	associate_public_ip_address = true
	source_dest_check = false
  root_block_device = {
    delete_on_termination = true
  }
  tags {
    Name = "${format("chef-provisioned-nat-%02d", count.index + 1)}"
  }
}
resource "aws_eip" "chef-provisioned-nat" {
	instance = "${aws_instance.chef-provisioned-nat.id}"
	vpc = true
}
resource "aws_route53_record" "nat" {
  zone_id = "${aws_route53_zone.ksplat.zone_id}"
  name = "nat.ksplat.com"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_instance.chef-provisioned-nat.public_dns}"]
}
#
# Public subnets
#
resource "aws_subnet" "us-west-2b-public" {
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  cidr_block = "${lookup(var.aws_cidrs, "us-west-2b-public")}"
	availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name} Public Subnet"
  }
}
resource "aws_subnet" "us-west-2c-public" {
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  cidr_block = "${lookup(var.aws_cidrs, "us-west-2c-public")}"
	availability_zone = "us-west-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name} Public Subnet"
  }
}
#
# Routing table for public subnets
#
resource "aws_route_table" "us-west-2-public" {
	vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.chef-provisioned-gw.id}"
	}
}
resource "aws_route_table_association" "us-west-2b-public" {
  subnet_id = "${aws_subnet.us-west-2b-public.id}"
  route_table_id = "${aws_route_table.us-west-2-public.id}"
}
resource "aws_route_table_association" "us-west-2c-public" {
  subnet_id = "${aws_subnet.us-west-2c-public.id}"
  route_table_id = "${aws_route_table.us-west-2-public.id}"
}
#
# Private subsets
#
resource "aws_subnet" "us-west-2b-private" {
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  cidr_block = "${lookup(var.aws_cidrs, "us-west-2b-private")}"
	availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name} Private Subnet"
  }
}
resource "aws_subnet" "us-west-2c-private" {
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  cidr_block = "${lookup(var.aws_cidrs, "us-west-2c-private")}"
	availability_zone = "us-west-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name} Private Subnet"
  }
}
#
# Routing table for private subnets
#
resource "aws_route_table" "us-west-2-private" {
	vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		instance_id = "${aws_instance.chef-provisioned-nat.id}"
	}
  tags {
		Name = "us-west-2-private"
	}
}
resource "aws_route_table_association" "us-west-2b-private" {
  subnet_id = "${aws_subnet.us-west-2b-private.id}"
	route_table_id = "${aws_route_table.us-west-2-private.id}"
}
resource "aws_route_table_association" "us-west-2c-private" {
  subnet_id = "${aws_subnet.us-west-2c-private.id}"
	route_table_id = "${aws_route_table.us-west-2-private.id}"
}
#
# Bastion
#
resource "aws_security_group" "chef-provisioned-bastion" {
	name = "chef-provisioned-bastion"
	description = "Allow SSH traffic from the internet"
	vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags {
    Name = "${var.cluster_name} Bastion Security Group"
	}
}
resource "aws_instance" "chef-provisioned-bastion" {
  ami = "${lookup(var.trusty-amis, var.aws_default_region)}"
	availability_zone = "us-west-2b"
  instance_type = "${lookup(var.instances, "chef-provisioned-bastion")}"
  count = "${lookup(var.instance_counts, "chef-provisioned-bastion")}"
  key_name = "${var.aws_key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.chef-provisioned-bastion.id}"]
  subnet_id = "${aws_subnet.us-west-2b-public.id}"
  root_block_device = {
    delete_on_termination = true
  }
  tags {
    Name = "${format("chef-provisioned-bastion-%02d", count.index + 1)}"
  }
}
resource "aws_eip" "chef-provisioned-bastion" {
	instance = "${aws_instance.chef-provisioned-bastion.id}"
	vpc = true
}
resource "aws_route53_record" "bastion" {
  zone_id = "${aws_route53_zone.ksplat.zone_id}"
  name = "bastion.ksplat.com"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_instance.chef-provisioned-bastion.public_dns}"]
}
#
# F5 Big IP
#
resource "aws_instance" "f5-bigip" {
  ami = "${lookup(var.f5-amis, var.aws_default_region)}"
	availability_zone = "us-west-2b"
  instance_type = "${lookup(var.instances, "f5-bigip")}"
  count = "${lookup(var.instance_counts, "f5-bigip")}"
  key_name = "${var.aws_key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.f5-bigip.id}"]
  subnet_id = "${aws_subnet.us-west-2b-public.id}"
	associate_public_ip_address = true
	source_dest_check = false
  root_block_device = {
    delete_on_termination = true
  }
  tags {
    Name = "${format("f5-bigip-%02d", count.index + 1)}"
  }
}
resource "aws_route53_record" "f5-bigip" {
  zone_id = "${aws_route53_zone.ksplat.zone_id}"
  name = "f5.ksplat.com"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_instance.f5-bigip.public_dns}"]
}
#
# AWS security groups
#
# Chef Server
resource "aws_security_group" "chef-server" {
  name = "chef-server"
  description = "Chef Server"
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  tags = {
    Name = "chef-server security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-server_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# HTTP (nginx)
resource "aws_security_group_rule" "chef-server_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# HTTPS (nginx)
resource "aws_security_group_rule" "chef-server_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# oc_bifrost
resource "aws_security_group_rule" "chef-server_allow_9463_tcp" {
  type = "ingress"
  from_port = 9463
  to_port = 9463
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# oc_bifrost (nginx LB)
resource "aws_security_group_rule" "chef-server_allow_9683_tcp" {
  type = "ingress"
  from_port = 9683
  to_port = 9683
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# opscode push-jobs
resource "aws_security_group_rule" "chef-server_allow_10000-10003_tcp" {
  type = "ingress"
  from_port = 10000
  to_port = 10003
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Allow all Chef Analytics
resource "aws_security_group_rule" "chef-server_allow_all_chef-analytics" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-analytics.id}"
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Allow all Jenkins
resource "aws_security_group_rule" "chef-server_allow_all_jenkins-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.jenkins-server.id}"
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Allow all Jenkins Workers
resource "aws_security_group_rule" "chef-server_allow_all_jenkins-worker" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.jenkins-worker.id}"
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Allow all Chef Compliance
resource "aws_security_group_rule" "chef-server_allow_all_chef-compliance" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-compliance.id}"
  security_group_id = "${aws_security_group.chef-server.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-server_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-server.id}"
}
#
# AWS security groups
#
# Chef Analytics
resource "aws_security_group" "chef-analytics" {
  name = "chef-analytics"
  description = "Chef Analytics Server"
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  tags = {
    Name = "chef-analytics security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-analytics_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# HTTP
resource "aws_security_group_rule" "chef-analytics_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# HTTPS
resource "aws_security_group_rule" "chef-analytics_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "chef-analytics_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# Allow all Jenkins
resource "aws_security_group_rule" "chef-analytics_allow_all_jenkins-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.jenkins-server.id}"
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# Allow all Chef Compliance
resource "aws_security_group_rule" "chef-analytics_allow_all_chef-compliance" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-compliance.id}"
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-analytics_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-analytics.id}"
}
#
# AWS security groups
#
# Chef Compliance
resource "aws_security_group" "chef-compliance" {
  name = "chef-compliance"
  description = "Chef compliance"
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  tags = {
    Name = "chef-compliance security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-compliance_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-compliance.id}"
}
# HTTPS
resource "aws_security_group_rule" "chef-compliance_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-compliance.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "chef-compliance_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.chef-compliance.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-compliance_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-compliance.id}"
}
#
# AWS security groups
#
# Chef Supermarket
resource "aws_security_group" "chef-supermarket" {
  name = "chef-supermarket"
  description = "Chef supermarket"
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  tags = {
    Name = "chef-supermarket security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "chef-supermarket_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# HTTP
resource "aws_security_group_rule" "chef-supermarket_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# HTTPS
resource "aws_security_group_rule" "chef-supermarket_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "chef-supermarket_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# Allow all Jenkins
resource "aws_security_group_rule" "chef-supermarket_allow_all_jenkins-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.jenkins-server.id}"
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "chef-supermarket_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.chef-supermarket.id}"
}
#
# AWS security groups
#
# Jenkins Server
resource "aws_security_group" "jenkins-server" {
  name = "jenkins-server"
  description = "Jenkins Server"
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  tags = {
    Name = "jenkins-server security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "jenkins-server_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-server.id}"
}
# HTTP
resource "aws_security_group_rule" "jenkins-server_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-server.id}"
}
# HTTPS
resource "aws_security_group_rule" "jenkins-server_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-server.id}"
}
# Delivery GIT
resource "aws_security_group_rule" "jenkins-server_allow_8989_tcp" {
  type = "ingress"
  from_port = 8989
  to_port = 8989
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-server.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "jenkins-server_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.jenkins-server.id}"
}
# Allow all Chef Analytics
resource "aws_security_group_rule" "jenkins-server_allow_all_chef-analytics" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-analytics.id}"
  security_group_id = "${aws_security_group.jenkins-server.id}"
}
# Allow all Jenkins Workers
resource "aws_security_group_rule" "jenkins-server_allow_all_jenkins-worker" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.jenkins-worker.id}"
  security_group_id = "${aws_security_group.jenkins-server.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "jenkins-server_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-server.id}"
}
#
# AWS security groups
#
# Jenkins Workers
resource "aws_security_group" "jenkins-worker" {
  name = "jenkins-worker"
  description = "Jenkins Workers"
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"
  tags = {
    Name = "jenkins-worker security group"
  }
}
# SSH - all
resource "aws_security_group_rule" "jenkins-worker_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-worker.id}"
}
# Allow all Chef Server
resource "aws_security_group_rule" "jenkins-worker_allow_all_chef-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.chef-server.id}"
  security_group_id = "${aws_security_group.jenkins-worker.id}"
}
# Allow all Jenkins
resource "aws_security_group_rule" "jenkins-worker_allow_all_jenkins-server" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.jenkins-server.id}"
  security_group_id = "${aws_security_group.jenkins-worker.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "jenkins-worker_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.jenkins-worker.id}"
}
#
# AWS security groups
#
# F5 Big IP
resource "aws_security_group" "f5-bigip" {
  name = "f5-bigip"
  description = "F5 Big IP"
  vpc_id = "${aws_vpc.chef-provisioned-vpc.id}"

  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "f5-bigip security group"
  }
}
# SSH
resource "aws_security_group_rule" "f5-bigip_allow_22_tcp_all" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.f5-bigip.id}"
}
# HTTP
resource "aws_security_group_rule" "f5-bigip_allow_80_tcp" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.f5-bigip.id}"
}
# HTTPS
resource "aws_security_group_rule" "f5-bigip_allow_443_tcp" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.f5-bigip.id}"
}
# Egress: ALL
resource "aws_security_group_rule" "f5-bigip_allow_0-65535_all" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.f5-bigip.id}"
}