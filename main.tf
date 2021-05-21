# Create VPC
resource "aws_vpc" "this" {
  # checkov:skip=CKV2_AWS_12: All traffic restricted from within the security group
  # checkov:skip=CKV2_AWS_1: Separate NACLs will be create per subnet group
  cidr_block                       = var.cidr_block
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  instance_tenancy                 = var.instance_tenancy
  assign_generated_ipv6_cidr_block = var.assign_ipv6_cidr_block

  tags = merge({
    Name = var.network_name
  }, var.tags)
}

# Additional CIDR block
resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count      = length(var.additional_cidr_blocks)
  vpc_id     = aws_vpc.this.id
  cidr_block = var.additional_cidr_blocks[count.index]
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_default_network_acl" "this" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id
}

data "aws_vpc" "this" {
  id = aws_vpc.this.id
}

# Create internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = "${var.network_name}-igw"
  }, var.tags)
}

data "aws_kms_key" "cw_log_group" {
  count  = var.cw_log_group_kms_key == null ? 0 : 1
  key_id = var.cw_log_group_kms_key
}

# Create cloudwatch log group for vpc flow logs
resource "aws_cloudwatch_log_group" "this" {
  count             = var.create_flow_logs && var.flow_logs_destination == "cloud-watch-logs" && var.flow_logs_cw_log_group_arn == "" ? 1 : 0
  name              = "${var.network_name}-flow-logs-group"
  kms_key_id        = join(",", data.aws_kms_key.cw_log_group.*.arn)
  retention_in_days = var.flow_logs_retention

  tags = merge({
    Name = "${var.network_name}-flow-logs-group"
  }, var.tags)
}

# Create IAM role for VPC flow logs
resource "aws_iam_role" "this" {
  count = var.create_flow_logs && var.flow_logs_destination == "cloud-watch-logs" && var.flow_logs_cw_log_group_arn == "" ? 1 : 0
  name  = "${var.network_name}-flow-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge({
    Name = "${var.network_name}-flow-logs-role"
  }, var.tags)
}

# Create IAM policy for VPC flow logs role
resource "aws_iam_role_policy" "this" {
  count = var.create_flow_logs && var.flow_logs_destination == "cloud-watch-logs" && var.flow_logs_cw_log_group_arn == "" ? 1 : 0
  name  = "${var.network_name}-flow-logs-policy"
  role  = aws_iam_role.this[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "random_id" "this" {
  byte_length = 8
}

data "aws_kms_key" "s3" {
  key_id = var.s3_kms_key
}

# Create S3 bucket for flow logs storage
resource "aws_s3_bucket" "this" {
  # checkov:skip=CKV_AWS_19: Default SSE is always in place
  # checkov:skip=CKV_AWS_18: Access logging not required
  # checkov:skip=CKV_AWS_144: CRR not required
  # checkov:skip=CKV_AWS_145: Using KMS key for SSE depends on user
  # checkov:skip=CKV_AWS_52: Enabling MFA delete depends on user
  # checkov:skip=CKV_AWS_21: Enabling versioning depends on user
  count         = var.create_flow_logs && var.flow_logs_destination == "s3" && var.flow_logs_bucket_arn == "" ? 1 : 0
  bucket        = "${var.network_name}-flow-logs-${random_id.this.hex}"
  acl           = "private"
  force_destroy = var.s3_force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.s3_kms_key == "alias/aws/s3" ? "AES256" : "aws:kms"
        kms_master_key_id = var.s3_kms_key == "alias/aws/s3" ? null : data.aws_kms_key.s3.id
      }
    }
  }

  versioning {
    enabled    = var.s3_enable_versioning
    mfa_delete = var.s3_enable_mfa_delete
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${var.network_name}-flow-logs-${random_id.this.hex}",
        "arn:aws:s3:::${var.network_name}-flow-logs-${random_id.this.hex}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "AWSLogDeliveryWrite",
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Resource": "arn:aws:s3:::${var.network_name}-flow-logs-${random_id.this.hex}/AWSLogs/${local.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Sid": "AWSLogDeliveryAclCheck",
      "Action": "s3:GetBucketAcl",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Resource": "arn:aws:s3:::${var.network_name}-flow-logs-${random_id.this.hex}"
    }
  ]
}
POLICY

  tags = merge({
    Name = "${var.network_name}-flow-logs-${random_id.this.hex}"
  }, var.tags)
}

resource "aws_s3_bucket_public_access_block" "this" {
  count                   = var.create_flow_logs && var.flow_logs_destination == "s3" && var.flow_logs_bucket_arn == "" ? 1 : 0
  bucket                  = join(",", aws_s3_bucket.this.*.id)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create VPC flow logs
resource "aws_flow_log" "this" {
  count                = var.create_flow_logs ? 1 : 0
  iam_role_arn         = var.flow_logs_destination == "cloud-watch-logs" ? aws_iam_role.this[0].arn : ""
  log_destination      = var.flow_logs_destination == "cloud-watch-logs" ? aws_cloudwatch_log_group.this[0].arn : aws_s3_bucket.this[0].arn
  log_destination_type = var.flow_logs_destination
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id

  tags = merge({
    Name = "${var.network_name}-flow-logs"
  }, var.tags)
}

# Create private hosted zone
resource "aws_route53_zone" "private" {
  count = var.create_private_zone == true ? 1 : 0
  name  = var.private_zone_domain

  vpc {
    vpc_id = aws_vpc.this.id
  }

  tags = merge({
    Name = "${var.network_name}-pvt-zone"
  }, var.tags)
}
