#This file can be named anything, since Terraform loads all files ending in .tf in a directory
variable "region" {
    default = "us-east-1"
}
variable "ec2_east_instance_name" {
    default = "my_first_ec2_east"
    description = "Name of the AWS EC2 instance EAST"
}
variable "ec2_west_instance_name" {
    default = "my_first_ec2_west"
    description = "Name of the AWS EC2 instance WEST"
}
variable "az" {
  default = "us-east-1a"
}

variable "k8s-ssh-key" {}

variable "ssh-key-2" {}

variable "cidr-ssh-allowed" {
    description = "A comma separated list of CIDR blocks to allow SSH connections from."
}

variable "cidr-ssh-2-allowed" {
    description = "A comma separated list of CIDR blocks to allow SSH connections from to the second EC2 instance."
}
output "public_domain_name_system"{
    value = "" /*aws_instance.sample_ec2_east*/
}