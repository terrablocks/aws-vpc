output "id" {
  value       = aws_vpc.this.id
  description = "ID of VPC created"
}

output "cidr_blocks" {
  value       = data.aws_vpc.this.cidr_block_associations.*.cidr_block
  description = "CIDR blocks associated to VPC"
}

output "igw_id" {
  value       = aws_internet_gateway.this.id
  description = "ID of internet gateway associated to VPC"
}

output "flow_log_id" {
  value       = var.create_flow_logs ? join(",", aws_flow_log.this.*.id) : null
  description = "ID of flow log created for VPC"
}

output "flow_log_arn" {
  value       = var.create_flow_logs ? join(",", aws_flow_log.this.*.arn) : null
  description = "ARN of flow log created for VPC"
}

output "cw_log_group_arn" {
  value       = var.create_flow_logs && var.flow_logs_destination == "cloud-watch-logs" ? (var.flow_logs_cw_log_group_arn == "" ? join(",", aws_cloudwatch_log_group.this.*.arn) : var.flow_logs_cw_log_group_arn) : null
  description = "ARN of cloudwatch log group created for storing VPC flow log"
}

output "bucket_arn" {
  value       = var.create_flow_logs && var.flow_logs_destination == "s3" ? (var.flow_logs_bucket_arn == "" ? join(",", aws_s3_bucket.this.*.arn) : var.flow_logs_bucket_arn) : null
  description = "ARN of bucket created for storing VPC flow log"
}

output "private_zone_id" {
  value       = var.create_private_zone ? join(", ", aws_route53_zone.private.*.zone_id) : null
  description = "Route53 private hosted zone id"
}

output "private_zone_ns" {
  value       = var.create_private_zone ? aws_route53_zone.private.*.name_servers : null
  description = "List of private hosted zone name servers"
}
