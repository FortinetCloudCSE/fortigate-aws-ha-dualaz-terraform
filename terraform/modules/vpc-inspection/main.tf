resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-igw"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr1
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr2
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-subnet2"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr1
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr2
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-subnet2"
  }
}

resource "aws_subnet" "hamgmt_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.hamgmt_subnet_cidr1
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-hamgmt-subnet1"
  }
}

resource "aws_subnet" "hamgmt_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.hamgmt_subnet_cidr2
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-hamgmt-subnet2"
  }
}

resource "aws_subnet" "attachment_subnet1" {
  count             = var.attachment_creation == 1 ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.attachment_subnet_cidr1
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-attachment-subnet1"
  }
}

resource "aws_subnet" "attachment_subnet2" {
  count             = var.attachment_creation == 1 ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.attachment_subnet_cidr2
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-attachment-subnet2"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-rt"
  }
}

resource "aws_route" "private_rtb_route_to_fgt1" {
  count                  = var.tgw_creation == 0 ? 1 : 0
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = var.fgt1_eni1_id
}

resource "aws_route" "private_rtb_route_to_tgw" {
  count                  = var.tgw_creation
  route_table_id         = aws_route_table.attachment_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "attachment_rtb_route_to_tgw" {
  count                  = var.tgw_creation
  route_table_id         = aws_route_table.attachment_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "attachment_rtb_route_to_cwan" {
  count                  = var.cwan_creation
  depends_on             = [aws_networkmanager_vpc_attachment.cwan_attachment]
  route_table_id         = aws_route_table.attachment_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = var.cwan_arn
}

resource "aws_route_table" "attachment_rt" {
  count  = var.attachment_creation == 1 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-attachment-rt"
  }
}

resource "aws_route_table_association" "public_rt_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association3" {
  subnet_id      = aws_subnet.hamgmt_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association4" {
  subnet_id      = aws_subnet.hamgmt_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_association1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_association2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "attachment_rt_association1" {
  count          = var.tgw_creation
  subnet_id      = aws_subnet.attachment_subnet1[0].id
  route_table_id = aws_route_table.attachment_rt[0].id
}

resource "aws_route_table_association" "attachment_rt_association2" {
  count          = var.tgw_creation
  subnet_id      = aws_subnet.attachment_subnet2[0].id
  route_table_id = aws_route_table.attachment_rt[0].id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  count                                           = var.tgw_creation
  subnet_ids                                      = [aws_subnet.attachment_subnet1[0].id, aws_subnet.attachment_subnet2[0].id]
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_association" {
  count                          = var.tgw_creation
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_security_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_propagation" {
  count                          = var.tgw_creation
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_spoke_route_table_id
}

resource "aws_ec2_transit_gateway_route" "tgw_defaultroute" {
  count                          = var.tgw_creation
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = var.tgw_spoke_route_table_id
}

resource "aws_networkmanager_vpc_attachment" "cwan_attachment" {
  count           = var.cwan_creation
  depends_on      = [var.cwan_policy_state]
  core_network_id = var.cwan_id
  subnet_arns     = [aws_subnet.attachment_subnet1[0].arn, aws_subnet.attachment_subnet2[0].arn]
  vpc_arn         = aws_vpc.vpc.arn
  options {
    appliance_mode_support = true
  }
  tags = {
    Name    = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc-attachment"
    segment = "${var.cwan_segment}"
  }
}