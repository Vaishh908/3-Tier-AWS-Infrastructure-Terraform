output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of private application subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of private database subnets"
  value       = module.vpc.private_db_subnet_ids
}

output "web_instance_ids" {
  description = "Web server EC2 instance IDs"
  value       = module.ec2.web_instance_ids
}

output "app_instance_ids" {
  description = "Application server EC2 instance IDs"
  value       = module.ec2.app_instance_ids
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.rds_endpoint
}
