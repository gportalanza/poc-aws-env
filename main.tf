resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true

    tags = {
        Name = "Guido_Testing"
    }
}

resource "aws_internet_gateway" "gate"{
    vpc_id = "${aws_vpc.main.id}"

    tags = {
        Name = "Guido_Testing"
    }
}

resource "aws_subnet" "public_subnet"{
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.100.0/24"
    availability_zone = "${var.az}"
    //To specify that all instances launched in this subnet should be ssigned a public IP:
    map_public_ip_on_launch = true

    #depends_on = ["aws_internet_gateway.gate"]

    tags = {
        Name = "Guido_Testing"
    }
}

resource "aws_route_table" "public_route"{
    vpc_id = "${aws_vpc.main.id}"

    route {
        /*cidr_block: Destination argument (required)*/
        cidr_block = "0.0.0.0/0"
        /*gateway_id: Target argument*/
        gateway_id = "${aws_internet_gateway.gate.id}"
    }

    #route para la segunda instancia
    route {
        /*cidr_block: Destination argument (required)*/
        cidr_block = "0.0.0.0/0"
        /*gateway_id: Target argument*/
        gateway_id = "${aws_internet_gateway.gate.id}"
    }

    tags = {
        Name = "Guido_Testing"
    }
}

#aws_route_table_association: Association route_table-subnet or route_table-internet gateway or rt-virtual private gw
resource "aws_route_table_association" "route_table_assoc" {
    subnet_id = "${aws_subnet.public_subnet.id}"
    route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_security_group" "aws_sg_ec2instances" {
  name = "aws_sg_ec2instances"
  description = "Allow inbound and outbound traffic"
  vpc_id = "${aws_vpc.main.id}"

  tags {
      Name = "Guido_Testing"
  }
}

//To allow ingress traffic from itself
resource "aws_security_group_rule" "allow_all_from_self" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = "${aws_security_group.aws_sg_ec2instances.id}"
}

resource "aws_security_group_rule" "aws_sg_ingress_rule" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "${split(",", var.cidr-ssh-allowed)}"
    #ipv6_cidr_blocks = "${split(",", var.cidr-ssh-allowed)}"
    security_group_id = "${aws_security_group.aws_sg_ec2instances.id}"
}

#security group for the second EC2 instance
resource "aws_security_group" "ec2-2" {
  name = "ec2-2"
  description = "Allow inbound and outbound traffic"
  vpc_id = "${aws_vpc.main.id}"

  tags {
      Name = "Guido_Testing"
  }
}
//To allow ingress traffic from itself (second EC2 instance)
resource "aws_security_group_rule" "allow_all_from_self" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = "${aws_security_group.ec2-2.id}"
}

resource "aws_security_group_rule" "ec2_2_ingress_rule" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "${split(",", var.cidr-ssh-2-allowed)}"
    #ipv6_cidr_blocks = "${split(",", var.cidr-ssh-allowed)}"
    security_group_id = "${aws_security_group.ec2-2.id}"
}
#DATA BLOCK, in which an aws data resource (in this case aws_ami) is read
#A data block requests that Terraform read from a given data source (aws_ami in this case)
#and export the result under the given local name ("ubuntu")
#aws_ami data source is used to get the ID of a registered AMI for use in other resources

data "aws_ami" "ubuntu" {
    most_recent = true #if 1+ result is returned use the  most recent AMI
    owners = ["amazon"] #List of AMI owners to limit the search. self = current account

    tags = {
        Name = "my_first_ec2_instance"
        Tested = "true"
    }
    #filter: One or more name/value pairs to filter off of.
    filter = {
        name = "name"
        values = ["ubuntu/images/hvm-ssd*"]
    }
}

#aws EC2 instance created using the by default aws configuration
resource "aws_instance" "instance-1" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${var.k8s-ssh-key}"
    subnet_id = "${aws_subnet.public_subnet.id}"
    availability_zone = "${var.az}"
    /*private_ip = "10.0.100.200"*/
    vpc_security_group_ids = ["${aws_security_group.aws_sg_ec2instances.id}"]

    tags = {
        Name = "HelloWorld_East"
    }
}

#second indtance in the same subnet as first instance
resource "aws_instance" "instance-2" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    #actually it would be best if a different key name is used for this second instance
    key_name = "${var.k8s-ssh-key}"
    subnet_id = "${aws_subnet.public_subnet.id}"
    availability_zone = "${var.az}"
    vpc_security_group_ids = ["${aws_security_group.ec2-2.id}"]

    tags = {
        Name = "EC2 instance 2"
    }
}