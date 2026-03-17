variable "access_key" {}
variable "secret_key" {}
variable "region" {
  description = "Provide the region to deploy the VPC in"
  type = string
  default = "us-east-1"
}
variable "availability_zone1" {
  description = "Provide the first availability zone to create the subnets in"
  type = string
  default = "us-east-1a"
}
variable "availability_zone2" {
  description = "Provide the second availability zone to create the subnets in"
  type = string
  default = "us-east-1b"
}
variable "inspection_vpc_cidr" {
  description = "Provide the network CIDR for the VPC"
  type = string
  default = "10.0.0.0/16"
}
variable "inspection_vpc_public_subnet_cidr1" {
  description = "Provide the network CIDR for the public subnet1 in inspection vpc"
  type = string
  default = "10.0.1.0/24"
}
variable "inspection_vpc_private_subnet_cidr1" {
  description = "Provide the network CIDR for the private subnet1 in inspection vpc"
  type = string
  default = "10.0.3.0/24"
}
variable "inspection_vpc_hamgmt_subnet_cidr1" {
  description = "Provide the network CIDR for the hamgmt subnet1 in inspection vpc"
  type = string
  default = "10.0.5.0/24"
}
variable "inspection_vpc_public_subnet_cidr2" {
  description = "Provide the network CIDR for the public subnet2 in inspection vpc"
  type = string
  default = "10.0.2.0/24"
}
variable "inspection_vpc_private_subnet_cidr2" {
  description = "Provide the network CIDR for the private subnet2 in inspection vpc"
  type = string
  default = "10.0.4.0/24"
}
variable "inspection_vpc_hamgmt_subnet_cidr2" {
  description = "Provide the network CIDR for the hamgmt subnet2 in inspection vpc"
  type = string
  default = "10.0.6.0/24"
}
variable "tgw_creation" {
  description = "Provide a 'yes' to deply a new TGW, twp spoke VPCs, and configure the inspection VPC and fgts accordingly, otherwise leave as 'no'"
  type = string
  default = "no"
}
variable "cwan_creation" {
  description = "Provide a 'yes' to deply a new CWAN and configure the inspection VPC and fgts accordingly, otherwise leave as 'no'"
  type = string
  default = "no"
}
variable "inspection_vpc_attachment_subnet_cidr1" {
  description = "Provide the network CIDR for the attachment subnet1 in inspection vpc"
  type = string
  default = "10.0.7.0/24"
}
variable "inspection_vpc_attachment_subnet_cidr2" {
  description = "Provide the network CIDR for the attachment subnet2 in inspection vpc"
  type = string
  default = "10.0.8.0/24"
}
variable "spoke_vpc1_cidr" {
  description = "Provide the network CIDR for the VPC"
  type = string
  default = "10.1.0.0/16"
}
variable "spoke_vpc1_private_subnet_cidr1" {
  description = "Provide the network CIDR for the private subnet1 in spoke vpc1"
  type = string
  default = "10.1.0.0/24"
}
variable "spoke_vpc1_private_subnet_cidr2" {
  description = "Provide the network CIDR for the private subnet2 in spoke vpc1"
  type = string
  default = "10.1.1.0/24"
}
variable "spoke_vpc2_cidr" {
  description = "Provide the network CIDR for the VPC"
  type = string
  default = "10.2.0.0/16"
}
variable "spoke_vpc2_private_subnet_cidr1" {
  description = "Provide the network CIDR for the private subnet1 in spoke vpc2"
  type = string
  default = "10.2.0.0/24"
}
variable "spoke_vpc2_private_subnet_cidr2" {
  description = "Provide the network CIDR for the private subnet2 in spoke vpc2"
  type = string
  default = "10.2.1.0/24"
}
variable "instance_type" {
  description = "Provide the instance type for the FortiGate instances"
  type = string
  default = "c6i.xlarge"
  /*
  Here is a list of supported instance types:
  c5.large 
  c5.xlarge 
  c5.2xlarge 
  c5.4xlarge 
  c5.9xlarge 
  c5.18xlarge 
  c5n.large 
  c5n.xlarge 
  c5n.2xlarge 
  c5n.4xlarge 
  c5n.9xlarge 
  c5n.18xlarge 
  c6i.large 
  c6i.xlarge 
  c6i.2xlarge 
  c6i.4xlarge 
  c6i.8xlarge 
  c6i.16xlarge 
  c6i.24xlarge 
  c6in.large 
  c6in.xlarge 
  c6in.2xlarge 
  c6in.4xlarge 
  c6in.8xlarge 
  c6in.16xlarge 
  c6g.large 
  c6g.xlarge 
  c6g.2xlarge 
  c6g.4xlarge 
  c6g.8xlarge 
  c6g.16xlarge 
  c6gn.large 
  c6gn.xlarge 
  c6gn.2xlarge 
  c6gn.4xlarge 
  c6gn.8xlarge 
  c6gn.16xlarge 
  c7g.large 
  c7g.xlarge 
  c7g.2xlarge 
  c7g.4xlarge 
  c7g.8xlarge 
  c7g.16xlarge 
  c7gn.large 
  c7gn.xlarge 
  c7gn.2xlarge 
  c7gn.4xlarge 
  c7gn.8xlarge 
  c7gn.16xlarge
  c8g.xlarge
  c8g.2xlarge
  c8g.4xlarge
  c8g.8xlarge
  c8g.16xlarge
  c8gn.large
  c8gn.xlarge
  c8gn.2xlarge
  c8gn.4xlarge
  c8gn.8xlarge
  c8gn.16xlarge
  */
}
variable "cidr_for_access" {
  description = "Provide a network CIDR for accessing the FortiGate instances"
  type = string
  default = ""
}
variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instances"
  type = string
  default = ""
}
variable "encrypt_volumes" {
  description = "Provide 'true' to encrypt the FortiGate instances OS and Log volumes with your account's KMS default master key for EBS.  Otherwise provide 'false' to leave unencrypted"
  type = string
  default = "true"
}
variable "only_private_ec2_api" {
  description = "Provide 'true' if only private EC2 API access is allowed for HAMgmt interfaces.  Otherwise provide 'false' to use dedicated EIPs to access the public EC2 API endpoints.  ***Note*** No EIP will be assigned to the HAMgmmt interfaces.  Login via the floating Cluster EIP or directly to each VM witht the private IP of the HAMgmt interface."
  type = string
  default = "false"
}
variable "fortios_version" {
  description = "Provide the verion of FortiOS to use (latest GA AMI will be used), 7.2, 7.4, or 7.6"
  type = string
  default = "7.4"
}
variable "license_type" {
  description = "Provide the license type for the FortiGate instances, byol flex, or payg"
  type = string
  default = "payg"
}
variable "fgt1_byol_license" {
  description = "[BYOL only] Provide the BYOL license filename for FortiGate1 and place the file in the root module folder"
  type = string
  default = ""
}
variable "fgt2_byol_license" {
  description = "[BYOL only]Provide the BYOL license filename for FortiGate2 and place the file in the root module folder"
  type = string
  default = ""
}
variable "fgt1_fortiflex_token" {
  description = "[FortiFlex only]Provide the FortiFlex Token for FortiGate1 (ie 1A2B3C4D5E6F7G8H9I0J)"
  type = string
  default = ""
}
variable "fgt2_fortiflex_token" {
  description = "[FortiFlex only]Provide the FortiFlex Token for FortiGate2 (ie 2B3C4D5E6F7G8H9I0J1K)"
  type = string
  default = ""
}
variable "inspection_vpc_public_subnet1_intrinsic_router_ip" {
  description = "Provide the IP address of the AWS intrinsic router (First IP from inspection_vpc_public_subnet1)"
  type = string
  default = "10.0.1.1"
}
variable "inspection_vpc_private_subnet1_intrinsic_router_ip" {
  description = "Provide the IP address of the AWS intrinsic router (First IP from inspection_vpc_private_subnet1)"
  type = string
  default = "10.0.3.1"
}
variable "inspection_vpc_hamgmt_subnet1_intrinsic_router_ip" {
  description = "Provide the IP address of the AWS intrinsic router (First IP from inspection_vpc_hamgmt_subnet1)"
  type = string
  default = "10.0.5.1"
}
variable "inspection_vpc_public_subnet2_intrinsic_router_ip" {
  description = "Provide the IP address of the AWS intrinsic router (First IP from inspection_vpc_public_subnet2)"
  type = string
  default = "10.0.2.1"
}
variable "inspection_vpc_private_subnet2_intrinsic_router_ip" {
  description = "Provide the IP address of the AWS intrinsic router (First IP from inspection_vpc_private_subnet2)"
  type = string
  default = "10.0.4.1"
}
variable "inspection_vpc_hamgmt_subnet2_intrinsic_router_ip" {
  description = "Provide the IP address of the AWS intrinsic router (First IP from inspection_vpc_hamgmt_subnet2)"
  type = string
  default = "10.0.6.1"
}
variable "fgt1_public_ip" {
  description = "Provide the IP address in CIDR form for the public interface of fgt1 (IP from inspection_vpc_public_subnet)"
  type = string
  default = "10.0.1.11/24"
}
variable "fgt1_private_ip" {
  description = "Provide the IP address in CIDR form for the private interface of fgt1 (IP from inspection_vpc_private_subnet)"
  type = string
  default = "10.0.3.11/24"
}
variable "fgt1_hamgmt_ip" {
  description = "Provide the IP address in CIDR form for the ha mgmt interface of fgt1 (IP from inspection_vpc_hamgmt_subnet)"
  type = string
  default = "10.0.5.11/24"
}
variable "fgt2_public_ip" {
  description = "Provide the IP address in CIDR form for the public interface of fgt2 (IP from inspection_vpc_public_subnet)"
  type = string
  default = "10.0.2.11/24"
}
variable "fgt2_private_ip" {
  description = "Provide the IP address in CIDR form for the private interface of fgt2 (IP from inspection_vpc_private_subnet)"
  type = string
  default = "10.0.4.11/24"
}
variable "fgt2_hamgmt_ip" {
  description = "Provide the IP address in CIDR form for the ha mgmt interface of fgt2 (IP from inspection_vpc_hamgmt_subnet)"
  type = string
  default = "10.0.6.11/24"
}
variable "tag_name_prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  type = string
  default = "stack-1"
}