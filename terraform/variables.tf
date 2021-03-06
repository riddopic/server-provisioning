# Variables
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "aws_default_region" {}
variable "aws_key_pair_name" {}
variable "aws_ami_user" {
  default = "ubuntu"
}
variable "instances" {
  default = {
    f5-bigip                 = "c3.xlarge"
    chef-provisioned-nat     = "t2.micro"
    chef-provisioned-bastion = "t2.micro"
  }
}
variable "instance_counts" {
  default = {
    f5-bigip                 = 1
    chef-provisioned-nat     = 1
    chef-provisioned-bastion = 1
  }
}
variable "centos-6-amis" {
  default = {
    us-west-2 = "ami-1255b321"
  }
}
variable "trusty-amis" {
  default = {
    us-west-2 = "ami-5189a661"
  }
}
variable "nat-amis" {
  default = {
    us-west-2 = "ami-5189a661"
  }
}
variable "f5-amis" {
  default = {
    us-west-2 = "ami-e2d735d1"
  }
}
variable "aws_cidrs" {
	default = {
		chef-provisioned-vpc = "10.0.0.0/16"
		us-west-2b-public    = "10.0.1.0/24"
		us-west-2c-public    = "10.0.2.0/24"
		us-west-2b-private   = "10.0.3.0/24"
		us-west-2c-private   = "10.0.4.0/24"
	}
}
variable "cluster_name" {
	default = "Chef Provisioned"
}
