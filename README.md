# Create a VPC for deploying your workload

![License](https://img.shields.io/github/license/terrablocks/aws-vpc?style=for-the-badge) ![Tests](https://img.shields.io/github/actions/workflow/status/terrablocks/aws-vpc/tests.yml?branch=main&label=Test&style=for-the-badge) ![Checkov](https://img.shields.io/github/actions/workflow/status/terrablocks/aws-vpc/checkov.yml?branch=main&label=Checkov&style=for-the-badge) ![Commit](https://img.shields.io/github/last-commit/terrablocks/aws-vpc?style=for-the-badge) ![Release](https://img.shields.io/github/v/release/terrablocks/aws-vpc?style=for-the-badge)

This terraform module will deploy the following services:
- VPC
  - Internet Gateway
  - Flow Logs (Optional)
- CloudWatch Log Group (Optional)
- S3 Bucket (Optional)
- IAM Role (Optional)
- Route53
  - Private Hosted Zone (Optional)

# Usage Instructions
## Example
```terraform
module "vpc" {
  source = "github.com/terrablocks/aws-vpc.git"

  network_name = "dev"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.15 |
| aws | >= 4.0.0 |
| random | >= 3.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network_name | Name to be used for VPC resources | `string` | n/a | yes |
| cidr_block | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| additional_cidr_blocks | Additional CIDR block to assicate with VPC | `list(string)` | `[]` | no |
| enable_dns_support | Whether to enable/disable DNS support in the VPC | `bool` | `true` | no |
| enable_dns_hostnames | Whether to enable/disable DNS hostnames in the VPC | `bool` | `true` | no |
| instance_tenancy | Tenancy option for instances launched into the VPC. **Valid values:** default, dedicated | `string` | `"default"` | no |
| assign_ipv6_cidr_block | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC | `bool` | `false` | no |
| create_flow_logs | Whether to enable flow logs for VPC | `bool` | `true` | no |
| flow_logs_destination | Destination to store VPC flow logs. Possible values: s3, cloud-watch-logs | `string` | `"cloud-watch-logs"` | no |
| cw_log_group_kms_key | Alias/ARN/ID of KMS key to use for Cloudwatch Log Group SSE | `string` | `null` | no |
| flow_logs_retention | Time period for which you want to retain VPC flow logs in CloudWatch log group. Default is 0 which means logs never expire. Possible values are 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 | `number` | `0` | no |
| flow_logs_cw_log_group_arn | ARN of CloudWatch Log Group to use for storing VPC flow logs | `string` | `""` | no |
| flow_logs_bucket_arn | ARN of S3 to use for storing VPC flow logs | `string` | `""` | no |
| s3_force_destroy | Delete bucket content before deleting bucket | `bool` | `true` | no |
| s3_kms_key | Alias/ID/ARN of KMS key to use for encrypting S3 bucket content | `string` | `"alias/aws/s3"` | no |
| s3_versioning_status | The versioning status of the S3 bucket. Valid values: `Enabled`, `Suspended` or `Disabled`. **Note:** Disabled can only be used if the versioning was never enabled on the bucket | `string` | `"Disabled"` | no |
| s3_enable_mfa_delete | Enable MFA delete for S3 bucket used to store flow logs | `bool` | `false` | no |
| create_private_zone | Whether to create private hosted zone for VPC | `bool` | `false` | no |
| private_zone_domain | Domain name to be used for private hosted zone | `string` | `"server.internal.com"` | no |
| tags | Map of key-value pair to associate with resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of VPC created |
| cidr_blocks | CIDR blocks associated to VPC |
| igw_id | ID of internet gateway associated to VPC |
| flow_log_id | ID of flow log created for VPC |
| flow_log_arn | ARN of flow log created for VPC |
| cw_log_group_arn | ARN of cloudwatch log group created for storing VPC flow log |
| bucket_arn | ARN of bucket created for storing VPC flow log |
| private_zone_id | Route53 private hosted zone id |
| private_zone_ns | List of private hosted zone name servers |
