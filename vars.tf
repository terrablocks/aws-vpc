variable "network_name" {
  type        = string
  description = "Name to be used for VPC resources"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC"
}

variable "additional_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "Additional CIDR block to assicate with VPC"
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "Whether to enable/disable DNS support in the VPC"
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Whether to enable/disable DNS hostnames in the VPC"
}

variable "instance_tenancy" {
  type        = string
  default     = "default"
  description = "Tenancy option for instances launched into the VPC. **Valid values:** default, dedicated"
}

variable "assign_ipv6_cidr_block" {
  type        = bool
  default     = false
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC"
}

variable "create_flow_logs" {
  type        = bool
  default     = true
  description = "Whether to enable flow logs for VPC"
}

variable "flow_logs_destination" {
  type        = string
  default     = "cloud-watch-logs"
  description = "Destination to store VPC flow logs. Possible values: s3, cloud-watch-logs"
}

variable "flow_logs_log_format" {
  type        = string
  default     = null
  description = "Specify the fields using the $${field-id} format, separated by spaces to include in the flow log record. E.g: $${version} $${account-id}. Leave it to `null` to use the AWS default format. Refer to [AWS doc](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html#flow-logs-fields) to learn what all fields can be included in the flow logs"
}

variable "cw_log_group_kms_key" {
  type        = string
  default     = null
  description = "Alias/ARN/ID of KMS key to use for Cloudwatch Log Group SSE"
}

variable "flow_logs_retention" {
  type        = number
  default     = 90
  description = "Time period for which you want to retain VPC flow logs in CloudWatch log group. Default is 0 which means logs never expire. Possible values are 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653"
}

variable "flow_logs_cw_log_group_arn" {
  type        = string
  default     = ""
  description = "ARN of CloudWatch Log Group to use for storing VPC flow logs"
}

variable "flow_logs_bucket_arn" {
  type        = string
  default     = ""
  description = "ARN of S3 to use for storing VPC flow logs"
}

variable "flow_logs_s3_file_format" {
  type        = string
  default     = "plain-text"
  description = "The format of log file delivered to the S3 bucket. **Valid values:** plain-text, parquet"
}

variable "flow_logs_s3_hive_compatible_partitions" {
  type        = bool
  default     = false
  description = "Whether to use Hive-compatible S3 prefixes to simplify the loading of new data into your Hive-compatible tools"
}

variable "flow_logs_s3_per_hour_partition" {
  type        = bool
  default     = true
  description = "Partition your logs per hour to reduce your query costs and get faster response if you have a large volume of logs and typically run queries targeted to a specific hour timeframe. Setting it to `false` will partition logs every 24 hours"
}

variable "s3_force_destroy" {
  type        = bool
  default     = true
  description = "Delete bucket content before deleting bucket"
}

variable "s3_kms_key" {
  type        = string
  default     = "alias/aws/s3"
  description = "Alias/ID/ARN of KMS key to use for encrypting S3 bucket content"
}

variable "s3_versioning_status" {
  type        = string
  default     = "Disabled"
  description = "The versioning status of the S3 bucket. Valid values: `Enabled`, `Suspended` or `Disabled`. **Note:** Disabled can only be used if the versioning was never enabled on the bucket"
}

variable "s3_enable_mfa_delete" {
  type        = bool
  default     = false
  description = "Enable MFA delete for S3 bucket used to store flow logs"
}

variable "create_private_zone" {
  type        = bool
  default     = false
  description = "Whether to create private hosted zone for VPC"
}

variable "private_zone_domain" {
  type        = string
  default     = "server.internal.com"
  description = "Domain name to be used for private hosted zone"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of key-value pair to associate with resources"
}
