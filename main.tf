terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">=3.1.0"
    }
  }
}

provider "aws" {
  /*access_key = "AKIAZJ4SL3S7PIUVIROU"
  secret_key = "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"
  */
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-east-1"
}

resource "aws_vpc" "vnet" {
  cidr_block = "${var.vpc}"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  tags = {
    "Name" = "Demo-VPC"
  }
}
resource "aws_subnet" "sub01" {
  vpc_id = "${aws_vpc.vnet.id}"
  availability_zone = "${var.availablityzone}"
  cidr_block = "${var.subnet}"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Demo-Subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vnet.id
  tags = {
    "Name" = "Demo-RT"
  }
}
resource "aws_route_table" "routeTable" {
  vpc_id = aws_vpc.vnet.id
  tags = {
    "Name" = "Demo-ROuteTable"

  }
}

resource "aws_route" "route" {
  route_table_id = "${aws_route_table.routeTable.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}

resource "aws_main_route_table_association" "rta" {
  vpc_id = aws_vpc.vnet.id
  route_table_id = aws_route_table.routeTable.id
}

resource "aws_route_table_association" "r" {
  subnet_id = aws_subnet.sub01.id
  route_table_id = aws_route_table.routeTable.id
}

resource "aws_security_group" "securityGroup" {
  vpc_id = aws_vpc.vnet.id
  name = "Allow Traffic"
  tags = {
    "Name" = "Demo-SG"
  }
}

resource "aws_security_group_rule" "SSH-B" {
  security_group_id = "${aws_security_group.securityGroup.id}"
  from_port =22
  to_port = 22
  type = "ingress"
  protocol = "6"
  cidr_blocks = [ "103.217.0.0/16" ]
}
resource "aws_security_group_rule" "HTTP-B" {
  security_group_id = "${aws_security_group.securityGroup.id}"
  from_port =80
  to_port = 80
  type = "ingress"
  protocol = "6"
  cidr_blocks = [ "103.217.0.0/16" ]
}
resource "aws_security_group_rule" "HTTPS-B" {
  security_group_id = "${aws_security_group.securityGroup.id}"
  from_port =443
  to_port = 443
  type = "ingress"
  protocol = "6"
  cidr_blocks = [ "103.217.0.0/16" ]
}
/*
resource "aws_security_group_rule" "allow_all_ip" {
  type              = "ingress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = "${aws_security_group.securityGroup.id}"
  cidr_blocks = [ "0.0.0.0/0" ]
}
*/
resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = "${aws_security_group.securityGroup.id}"
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_network_interface" "nic" {
  subnet_id = aws_subnet.sub01.id
  security_groups = [ "${resource.aws_security_group.securityGroup.id}" ]
  tags = {
    "Name" = "NIC01"
  }
}

resource "aws_instance" "vm" {
  ami = "ami-02e136e904f3da870"
  instance_type = "t2.micro"
  instance_initiated_shutdown_behavior = "stop"
  tags = {
    "Name" = "Demo-EC2"
  }
  subnet_id = aws_subnet.sub01.id
  availability_zone = "${var.availablityzone}"
  disable_api_termination = false
  associate_public_ip_address = true
  monitoring = false
  tenancy = "default"
  root_block_device {
    volume_size = 10
    delete_on_termination = true
    encrypted = true    
  }
  vpc_security_group_ids = [ "${resource.aws_security_group.securityGroup.id}" ]
  key_name = "ec2-user"
}

resource "aws_key_pair" "keypair" {
  key_name = "ec2-user"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8oldMc0TSMD+wsi0PTORlye/5E1VKfO0VrT5jFW7aF6C6NxSRuICAtKpCNZGnpNVLOz1NXVVuo9wbXAkk6DuUSPFXf8jH93PrAESeKqqL2dOllBMAs4eqqfJa21qMo17ALtoIwwK8s2cp0WoB6oqjZEuVEORXJACnsMOL9IQQg9S7FOAfVoQqev/7R9Vg14itmIxhFqpcN78wjToynn6vTevZFYuw0I9J0InRtwY4RzGzhiQ66fXrV08W2BFjdSm30+fsk9jXOLAPAAwmPqTn7u3EGlwVibq3A++NV+rKD00cE0Qv2+d5BWhTpeyeS+anSRbAvrxfBGaoPgBnZ1YT2HZSev5PC16mzRG4csKTbY5fVZDzAYpbmtkuyvoBDOHl8RNF71VbFzcfSeKWBEixoiR4T0X1VAY1icXnnzkjNK94V0Vf4aWUfpbcemcotmG8x+evtF+jmuxe0mEWzn20zFdEmjHWb10zzaN2Lr/kWJjoQk5I5V9zdwIjkn1Vvz0="
}
