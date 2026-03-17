provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  account_id_base64 = base64encode(local.account_id)
}

resource "aws_vpc_endpoint" "ec2_vpcendpoint" {
  count = var.only_private_ec2_api == "true" ? 1 : 0
  service_name = "com.amazonaws.${var.region}.ec2"
  subnet_ids = [var.hamgmt_subnet1_id, var.hamgmt_subnet2_id]
  vpc_id = var.vpc_id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.secgrp.id]
  private_dns_enabled = true
}

resource "aws_iam_role" "iam-role" {
  name = "${var.tag_name_prefix}-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.tag_name_prefix}-iam-instance-profile"
  role = "${var.tag_name_prefix}-iam-role"
}

resource "aws_iam_role_policy" "iam-role-policy" {
  name = "${var.tag_name_prefix}-iam-role-policy"
  role = aws_iam_role.iam-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Failover",
	  "Effect": "Allow",
      "Action": [
		"ec2:AssociateAddress",
		"ec2:DescribeAddresses",
		"ec2:DescribeInstances",
		"ec2:DescribeRouteTables",
		"ec2:DescribeVpcEndpoints",
		"ec2:ReplaceRoute"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SDNConnectorFortiView",
	  "Effect": "Allow",
      "Action": [
		"ec2:DescribeNetworkInterfaces",
		"ec2:DescribeRegions",
		"eks:DescribeCluster",
		"eks:ListClusters",
		"inspector:DescribeFindings",
		"inspector:ListFindings"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

variable "fgtami" {
  type = map(any)
  default = {
    "7.2" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.2.*)*|33ndn84xbrajb9vmu5lxnfpjq"
		"flex" = "FortiGate-VMARM64-AWS *(7.2.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.2.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.2.*)*|dlaioq277sglm5mw1y1dmeuqa"
		"flex" = "FortiGate-VM64-AWS *(7.2.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.2.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    },
    "7.4" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.4.*)*|33ndn84xbrajb9vmu5lxnfpjq"
		"flex" = "FortiGate-VMARM64-AWS *(7.4.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.4.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.4.*)*|dlaioq277sglm5mw1y1dmeuqa"
		"flex" = "FortiGate-VM64-AWS *(7.4.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.4.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    },
    "7.6" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.6.*)*|33ndn84xbrajb9vmu5lxnfpjq"
		"flex" = "FortiGate-VMARM64-AWS *(7.6.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.6.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.6.*)*|dlaioq277sglm5mw1y1dmeuqa"
		"flex"  = "FortiGate-VM64-AWS *(7.6.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.6.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    }
  }
}

locals {
  instance_family = split(".", "${var.instance_type}")[0]
  graviton = (local.instance_family == "c6g") || (local.instance_family == "c6gn") || (local.instance_family == "c7g") || (local.instance_family == "c7gn") || (local.instance_family == "c8g") || (local.instance_family == "c8gn") ? true : false
  arch = local.graviton == true ? "arm" : "intel"
  ami_search_string = split("|", "${var.fgtami[var.fortios_version][local.arch][var.license_type]}")[0]
  product_code = split("|", "${var.fgtami[var.fortios_version][local.arch][var.license_type]}")[1]
}

data "aws_ami" "fortigate_ami" {
  most_recent = true
  owners = ["aws-marketplace"]

  filter {
    name   = "name"
    values = [local.ami_search_string]
  }
  filter {
    name   = "product-code"
    values = [local.product_code]
  }
}

resource "aws_security_group" "secgrp" {
  name = "${var.tag_name_prefix}-secgrp"
  description = "secgrp"
  vpc_id = var.vpc_id
  ingress {
    description = "Allow remote access to FGT"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.cidr_for_access]
  }
  ingress {
    description = "Allow local VPC access to FGT"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgt-secgrp"
  }
}

resource "aws_security_group_rule" "ha_rule" {
  security_group_id = aws_security_group.secgrp.id
  type = "ingress"
  description = "Allow FGTs to access each other"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  source_security_group_id = aws_security_group.secgrp.id
}

resource "aws_network_interface" "fgt1_eni0" {
  subnet_id = var.public_subnet1_id
  security_groups = [ aws_security_group.secgrp.id ]
  private_ips = [ "${element("${split("/", var.fgt1_public_ip)}", 0)}" ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt1-eni0"
  }
}

resource "aws_network_interface" "fgt1_eni1" {
  subnet_id = var.private_subnet1_id
  security_groups = [ aws_security_group.secgrp.id ]
  private_ips = [ "${element("${split("/", var.fgt1_private_ip)}", 0)}", ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt1-eni1"
  }
}

resource "aws_network_interface" "fgt1_eni2" {
  subnet_id = var.hamgmt_subnet1_id
  security_groups = [ aws_security_group.secgrp.id ]
  private_ips = [ "${element("${split("/", var.fgt1_hamgmt_ip)}", 0)}" ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt1-eni2"
  }
}

resource "aws_eip" "fgt1_hamgmt_eip" {
  count = var.only_private_ec2_api == "false" ? 1 : 0
  depends_on = [
    aws_eip.fgt1_hamgmt_eip,
    aws_instance.fgt1,
    aws_network_interface.fgt2_eni2
  ]
  domain = "vpc"
  network_interface = aws_network_interface.fgt1_eni2.id
  associate_with_private_ip = element("${split("/", var.fgt1_hamgmt_ip)}", 0)
  tags = {
    Name = "${var.tag_name_prefix}-fgt1-hamgmt-eip"
  }
}

resource "aws_eip" "cluster_eip" {
  depends_on = [
    aws_eip.cluster_eip,
    aws_instance.fgt1,
    aws_network_interface.fgt2_eni0
  ]
  domain = "vpc"
  network_interface = aws_network_interface.fgt1_eni0.id
  associate_with_private_ip = element("${split("/", var.fgt1_public_ip)}", 0)
  tags = {
    Name =  "${var.tag_name_prefix}-cluster-eip"
  }
}

resource "aws_instance" "fgt1" {
  ami = data.aws_ami.fortigate_ami.id
  instance_type = var.instance_type
  availability_zone = var.availability_zone1
  key_name = var.keypair
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.id
  user_data = data.template_file.fgt1_userdata.rendered
  root_block_device {
    volume_type = "gp2"
    encrypted = var.encrypt_volumes
    volume_size = "2"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
    encrypted = var.encrypt_volumes
  }
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.fgt1_eni0.id
  }
  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.fgt1_eni1.id
  }
  network_interface {
    device_index = 2
    network_interface_id = aws_network_interface.fgt1_eni2.id
  }
  tags = {
	Name = "${var.tag_name_prefix}-fgt1"
  }
}

data "template_file" "fgt1_userdata" {
  template = "${file("${path.module}/fgt1-userdata.tpl")}"
  
  vars = {
    ha_pass = local.account_id_base64
    fgt1_public_ip = var.fgt1_public_ip
    fgt1_private_ip = var.fgt1_private_ip
    fgt1_hamgmt_ip = var.fgt1_hamgmt_ip
    vpc_cidr = var.vpc_cidr
    public_subnet_intrinsic_router_ip = var.public_subnet1_intrinsic_router_ip
    private_subnet_intrinsic_router_ip = var.private_subnet1_intrinsic_router_ip
    hamgmt_subnet_intrinsic_router_ip = var.hamgmt_subnet1_intrinsic_router_ip
    fgt2_hamgmt_ip = "${element("${split("/", var.fgt2_hamgmt_ip)}", 0)}"
	license_type = var.license_type
	license_file = "${path.root}/${var.fgt1_byol_license}"
	license_token = var.fgt1_fortiflex_token
	private_ec2_api = var.only_private_ec2_api
  }
}

resource "aws_network_interface" "fgt2_eni0" {
  subnet_id = var.public_subnet2_id
  security_groups = [ aws_security_group.secgrp.id ]
  private_ips = [ "${element("${split("/", var.fgt2_public_ip)}", 0)}" ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt2-eni0"
  }
}

resource "aws_network_interface" "fgt2_eni1" {
  subnet_id = var.private_subnet2_id
  security_groups = [ aws_security_group.secgrp.id ]
  private_ips = [ "${element("${split("/", var.fgt2_private_ip)}", 0)}" ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt2-eni1"
  }
}

resource "aws_network_interface" "fgt2_eni2" {
  subnet_id = var.hamgmt_subnet2_id
  security_groups = [ aws_security_group.secgrp.id ]
  private_ips = [ "${element("${split("/", var.fgt2_hamgmt_ip)}", 0)}" ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt2-eni2"
  }
}

resource "aws_eip" "fgt2_hamgmt_eip" {
  count = var.only_private_ec2_api == "false" ? 1 : 0
  depends_on = [
    aws_eip.fgt2_hamgmt_eip,
    aws_instance.fgt2,
    aws_network_interface.fgt2_eni2
  ]
  domain = "vpc"
  network_interface = aws_network_interface.fgt2_eni2.id
  associate_with_private_ip = element("${split("/", var.fgt2_hamgmt_ip)}", 0)
  tags = {
    Name = "${var.tag_name_prefix}-fgt2-hamgmt-eip"
  }
}

resource "aws_instance" "fgt2" {
  ami = data.aws_ami.fortigate_ami.id
  instance_type = var.instance_type
  availability_zone = var.availability_zone2
  key_name = var.keypair
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.id
  user_data = data.template_file.fgt2_userdata.rendered
  root_block_device {
    volume_type = "gp2"
    encrypted = var.encrypt_volumes
    volume_size = "2"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
    encrypted = var.encrypt_volumes
  }
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.fgt2_eni0.id
  }
  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.fgt2_eni1.id
  }
  network_interface {
    device_index = 2
    network_interface_id = aws_network_interface.fgt2_eni2.id
  }
  tags = {
	Name = "${var.tag_name_prefix}-fgt2"
  }
}

data "template_file" "fgt2_userdata" {
  template = "${file("${path.module}/fgt2-userdata.tpl")}"
  
  vars = {
    ha_pass = local.account_id_base64
    fgt2_public_ip = var.fgt2_public_ip
    fgt2_private_ip = var.fgt2_private_ip
    fgt2_hamgmt_ip = var.fgt2_hamgmt_ip
    vpc_cidr = var.vpc_cidr
    public_subnet_intrinsic_router_ip = var.public_subnet2_intrinsic_router_ip
    private_subnet_intrinsic_router_ip = var.private_subnet2_intrinsic_router_ip
    hamgmt_subnet_intrinsic_router_ip = var.hamgmt_subnet2_intrinsic_router_ip
    fgt1_hamgmt_ip = "${element("${split("/", var.fgt1_hamgmt_ip)}", 0)}"
	license_type = var.license_type
	license_file = "${path.root}/${var.fgt2_byol_license}"
	license_token = var.fgt2_fortiflex_token
	private_ec2_api = var.only_private_ec2_api
  }
}