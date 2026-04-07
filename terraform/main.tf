locals {
  create_tgw    = var.cwan_creation == "no" && var.tgw_creation == "yes" ? 1 : 0
  create_cwan   = var.cwan_creation == "yes" && var.tgw_creation == "no" ? 1 : 0
  create_spokes = var.cwan_creation == "yes" || var.tgw_creation == "yes" ? 1 : 0
}

module "transit-gw" {
  source = "./modules/tgw"
  count  = local.create_tgw
  region = var.region

  tag_name_prefix = var.tag_name_prefix
}

module "cloud-wan" {
  source = "./modules/cwan"
  count  = local.create_cwan
  region = var.region

  tag_name_prefix = var.tag_name_prefix
}

module "inspection-vpc" {
  source = "./modules/vpc-inspection"
  region = var.region

  availability_zone1          = var.availability_zone1
  availability_zone2          = var.availability_zone2
  vpc_cidr                    = var.inspection_vpc_cidr
  public_subnet_cidr1         = var.inspection_vpc_public_subnet_cidr1
  public_subnet_cidr2         = var.inspection_vpc_public_subnet_cidr2
  private_subnet_cidr1        = var.inspection_vpc_private_subnet_cidr1
  private_subnet_cidr2        = var.inspection_vpc_private_subnet_cidr2
  hamgmt_subnet_cidr1         = var.inspection_vpc_hamgmt_subnet_cidr1
  hamgmt_subnet_cidr2         = var.inspection_vpc_hamgmt_subnet_cidr2
  attachment_subnet_cidr1     = var.inspection_vpc_attachment_subnet_cidr1
  attachment_subnet_cidr2     = var.inspection_vpc_attachment_subnet_cidr2
  attachment_creation         = local.create_spokes
  fgt1_eni1_id                = module.fgcp.fgt1_eni1_id
  tgw_creation                = local.create_tgw
  cwan_creation               = local.create_cwan
  transit_gateway_id          = local.create_tgw == 1 ? module.transit-gw[0].tgw_id : ""
  tgw_spoke_route_table_id    = local.create_tgw == 1 ? module.transit-gw[0].tgw_spoke_route_table_id : ""
  tgw_security_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_security_route_table_id : ""
  cwan_id                     = local.create_cwan == 1 ? module.cloud-wan[0].cwan_id : ""
  cwan_arn                    = local.create_cwan == 1 ? module.cloud-wan[0].cwan_arn : ""
  cwan_segment                = "inspection"
  cwan_policy_state           = local.create_cwan == 1 ? module.cloud-wan[0].cwan_policy_state : ""

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "inspection"
}

module "fgcp" {
  source = "./modules/fgt-fgcp"
  region = var.region

  availability_zone1 = var.availability_zone1
  availability_zone2 = var.availability_zone2
  vpc_id             = module.inspection-vpc.vpc_id
  vpc_cidr           = var.inspection_vpc_cidr
  public_subnet1_id  = module.inspection-vpc.public_subnet1_id
  private_subnet1_id = module.inspection-vpc.private_subnet1_id
  hamgmt_subnet1_id  = module.inspection-vpc.hamgmt_subnet1_id
  public_subnet2_id  = module.inspection-vpc.public_subnet2_id
  private_subnet2_id = module.inspection-vpc.private_subnet2_id
  hamgmt_subnet2_id  = module.inspection-vpc.hamgmt_subnet2_id

  cidr_for_access                     = var.cidr_for_access
  keypair                             = var.keypair
  encrypt_volumes                     = var.encrypt_volumes
  instance_type                       = var.instance_type
  only_private_ec2_api                = var.only_private_ec2_api
  fortios_version                     = var.fortios_version
  license_type                        = var.license_type
  fgt1_byol_license                   = var.fgt1_byol_license
  fgt2_byol_license                   = var.fgt2_byol_license
  fgt1_fortiflex_token                = var.fgt1_fortiflex_token
  fgt2_fortiflex_token                = var.fgt2_fortiflex_token
  public_subnet1_intrinsic_router_ip  = var.inspection_vpc_public_subnet1_intrinsic_router_ip
  private_subnet1_intrinsic_router_ip = var.inspection_vpc_private_subnet1_intrinsic_router_ip
  hamgmt_subnet1_intrinsic_router_ip  = var.inspection_vpc_hamgmt_subnet1_intrinsic_router_ip
  public_subnet2_intrinsic_router_ip  = var.inspection_vpc_public_subnet2_intrinsic_router_ip
  private_subnet2_intrinsic_router_ip = var.inspection_vpc_private_subnet2_intrinsic_router_ip
  hamgmt_subnet2_intrinsic_router_ip  = var.inspection_vpc_hamgmt_subnet2_intrinsic_router_ip
  fgt1_public_ip                      = var.fgt1_public_ip
  fgt1_private_ip                     = var.fgt1_private_ip
  fgt1_hamgmt_ip                      = var.fgt1_hamgmt_ip
  fgt2_public_ip                      = var.fgt2_public_ip
  fgt2_private_ip                     = var.fgt2_private_ip
  fgt2_hamgmt_ip                      = var.fgt2_hamgmt_ip

  tag_name_prefix = var.tag_name_prefix
}

module "spoke-vpc1" {
  source = "./modules/vpc-spoke"
  count  = local.create_spokes
  region = var.region

  availability_zone1          = var.availability_zone1
  availability_zone2          = var.availability_zone2
  vpc_cidr                    = var.spoke_vpc1_cidr
  private_subnet_cidr1        = var.spoke_vpc1_private_subnet_cidr1
  private_subnet_cidr2        = var.spoke_vpc1_private_subnet_cidr2
  tgw_creation                = local.create_tgw
  cwan_creation               = local.create_cwan
  transit_gateway_id          = local.create_tgw == 1 ? module.transit-gw[0].tgw_id : ""
  tgw_spoke_route_table_id    = local.create_tgw == 1 ? module.transit-gw[0].tgw_spoke_route_table_id : ""
  tgw_security_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_security_route_table_id : ""
  cwan_id                     = local.create_cwan == 1 ? module.cloud-wan[0].cwan_id : ""
  cwan_arn                    = local.create_cwan == 1 ? module.cloud-wan[0].cwan_arn : ""
  cwan_segment                = "production"
  cwan_policy_state           = local.create_cwan == 1 ? module.cloud-wan[0].cwan_policy_state : ""

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "spoke1"
}

module "spoke-vpc2" {
  source = "./modules/vpc-spoke"
  count  = local.create_spokes
  region = var.region

  availability_zone1          = var.availability_zone1
  availability_zone2          = var.availability_zone2
  vpc_cidr                    = var.spoke_vpc2_cidr
  private_subnet_cidr1        = var.spoke_vpc2_private_subnet_cidr1
  private_subnet_cidr2        = var.spoke_vpc2_private_subnet_cidr2
  tgw_creation                = local.create_tgw
  cwan_creation               = local.create_cwan
  transit_gateway_id          = local.create_tgw == 1 ? module.transit-gw[0].tgw_id : ""
  tgw_spoke_route_table_id    = local.create_tgw == 1 ? module.transit-gw[0].tgw_spoke_route_table_id : ""
  tgw_security_route_table_id = local.create_tgw == 1 ? module.transit-gw[0].tgw_security_route_table_id : ""
  cwan_id                     = local.create_cwan == 1 ? module.cloud-wan[0].cwan_id : ""
  cwan_arn                    = local.create_cwan == 1 ? module.cloud-wan[0].cwan_arn : ""
  cwan_segment                = "development"
  cwan_policy_state           = local.create_cwan == 1 ? module.cloud-wan[0].cwan_policy_state : ""

  tag_name_prefix = var.tag_name_prefix
  tag_name_unique = "spoke2"
}