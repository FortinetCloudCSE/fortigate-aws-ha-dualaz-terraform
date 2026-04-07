/*
Please update the example values here to override the default values in variables.tf.
Any variables in variables.tf can be overriden here.
Overriding variables here keeps the variables.tf as a clean local reference.
*/

/*
Credentials are automatically detected from standard AWS authentication means:
 - AWS creds file used with AWS CLI (~/.aws/credentials)
 - Environment variables (AWSACCESSKEYID, AWSSECRETACCESSKEY)
 - IAM Roles (preferred for EC2, ECS)
 - AWS SSO (aws sso login)
For more documentation on how to authenticate, reference the link below: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration
*/

# Specify the region and AZs to use.
region             = ""
availability_zone1 = ""
availability_zone2 = ""

/*
To deploy a new TGW and two spoke VPCs, specify 'yes'.
To deploy a new CWAN and two spoke VPCs, specify 'yes'.
Only specify yes for tgw_creation or cwan_creation not both.
*/
cwan_creation = "no"
tgw_creation  = "no"

# Specify the name of the keypair that the FGTs will use.
keypair = ""

# Specify the CIDR block which you will be logging into the FGTs from.
cidr_for_access = ""

# Specify a tag prefix that will be used to name resources.
tag_name_prefix = "poc"

# Specify the FortiOS version to use 7.2, 7.4, or 7.6
fortios_version = "7.4"

/*
For license_type, specify byol, flex, or payg.

To use traditional byol license files, place the license files in this root directory (same as this file) and specify the file names.
Otherwise, leave these as empty strings.
fgt1_byol_license = "fgt1-license.lic"
fgt2_byol_license = "fgt2-license.lic"

To use FortiFlex tokens, please provide the token values like so.
Otherwise, leave these as empty strings.
fgt1_fortiflex_token = "1A2B3C4D5E6F7G8H9I0J"
fgt2_fortiflex_token = "2B3C4D5E6F7G8H9I0J1K"
*/
license_type         = "payg"
fgt1_byol_license    = ""
fgt2_byol_license    = ""
fgt1_fortiflex_token = ""
fgt2_fortiflex_token = ""