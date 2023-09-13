# * VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this.id, null)
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.this.arn, null)
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.this.cidr_block, null)
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on the VPC creation"
  value       = try(aws_vpc.this.default_security_group_id, null)
}

output "default_nacl_id" {
  description = "The ID of the default NACL"
  value       = try(aws_vpc.this.default_network_acl_id, null)
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = try(aws_vpc.this.default_route_table_id, null)
}

# * Internet Gateway
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.this.id, null)
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = try(aws_internet_gateway.this.arn, null)
}

# * Public Subnets
output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of the public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnets" {
  description = "List of the public subnets"
  value       = aws_subnet.public
}

output "public_subnet_cidr_blocks" {
  description = "List of cidr blocks of the public subnets"
  value       = compact(aws_subnet.public[*].cidr_block)
}

output "public_route_table_ids" {
  description = "List of IDs of the public route tables"
  value       = aws_route_table.public[*].id
}

output "public_internet_gateway_route_id" {
  description = "The ID of the internet gateway route"
  value       = try(aws_route.public_internet_gateway[0].id, null)
}

output "public_route_table_association_ids" {
  description = "List of IDs of the public route table association"
  value       = aws_route_table_association.public[*].id
}

# * Private Subnets
output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of the private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnets" {
  description = "List of the private subnets"
  value       = aws_subnet.private
}
output "private_subnet_cidr_blocks" {
  description = "List of cidr blocks of the private subnets"
  value       = compact(aws_subnet.private[*].cidr_block)
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "private_nat_gateway_route_ids" {
  description = "List of IDs of the private nat gateway route"
  value       = aws_route.private_nat[*].id
}

output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value       = aws_route_table_association.private[*].id
}

# * Metadata Subnets
output "metadata_subnet_ids" {
  description = "List of IDs of the metadata subnets"
  value       = aws_subnet.metadata[*].id
}

output "metadata_subnet_arns" {
  description = "List of ARNs of the metadata subnets"
  value       = aws_subnet.metadata[*].arn
}

output "metadata_subnets" {
  description = "List of the metadata subnets"
  value       = aws_subnet.metadata
}

output "metadata_subnet_cidr_blocks" {
  description = "List of cidr blocks of the metadata subnets"
  value       = compact(aws_subnet.metadata[*].cidr_block)
}

output "metadata_subnet_group_id" {
  description = "ID of the metadata subnet group"
  value       = try(aws_db_subnet_group.metadata[0].id, null)
}

output "metadata_subnet_group_name" {
  description = "Name of the metadata subnet group"
  value       = try(aws_db_subnet_group.metadata[0].id, null)
}

output "metadata_route_table_ids" {
  description = "List of IDs of the metadata route tables"
  value       = length(aws_route_table.metadata[*].id) > 0 ? aws_route_table.metadata[*].id : aws_route_table.private[*].id
}

output "metadata_route_table_association_ids" {
  description = "List of IDs of the metadata route table association"
  value       = aws_route_table_association.metadata[*].id
}

# * Database Subnets
output "database_subnet_ids" {
  description = "List of IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnet_arns" {
  description = "List of ARNs of the database subnets"
  value       = aws_subnet.database[*].arn
}

output "database_subnet_cidr_blocks" {
  description = "List of cidr blocks of the database subnets"
  value       = compact(aws_subnet.database[*].cidr_block)
}
output "database_subnet_group_id" {
  description = "ID of the database subnet group"
  value       = try(aws_db_subnet_group.database[0].id, null)
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = try(aws_db_subnet_group.database[0].name, null)
}

output "database_route_table_ids" {
  description = "List of IDs of the database route tables"
  value       = length(aws_route_table.database[*].id) > 0 ? aws_route_table.database[*].id : aws_route_table.private[*].id
}

output "database_nat_gateway_route_ids" {
  description = "List of IDs of the nat gateway route"
  value       = aws_route.database_nat[*].id
}

output "database_route_table_association_ids" {
  description = "List of IDs of the database route table association"
  value       = aws_route_table_association.database[*].id
}

# * Redshift Subnets
output "redshift_subnet_ids" {
  description = "List of IDs of the redshift subnets"
  value       = aws_subnet.redshift[*].id
}

output "redshift_subnet_arns" {
  description = "List of ARNs of the redshift subnets"
  value       = aws_subnet.redshift[*].arn
}

output "redshift_subnet_cidr_blocks" {
  description = "List of cidr blocks of the redshift subnets"
  value       = compact(aws_subnet.redshift[*].cidr_block)
}

output "redshift_subnet_group_id" {
  description = "ID of the redshift subnet group"
  value       = try(aws_db_subnet_group.database[0].id, null)
}

output "redshift_subnet_group_name" {
  description = "Name of the redshift subnet group"
  value       = try(aws_db_subnet_group.database[0].name, null)
}

output "redshift_route_table_ids" {
  description = "List of IDs of the redshift route table"
  value       = length(aws_route_table.redshift[*].id) > 0 ? aws_route_table.redshift[*].id : aws_route_table.private[*].id
}

output "redshift_route_table_association_ids" {
  description = "List of IDs of the redshift route table association"
  value       = aws_route_table_association.redshift[*].id
}

# * EMR Subnets
output "emr_subnet_ids" {
  description = "List of IDs of the emr subnets"
  value       = aws_subnet.emr[*].id
}

output "emr_subnet_arns" {
  description = "List of ARNs of the emr subnets"
  value       = aws_subnet.emr[*].arn
}

output "emr_subnet_cidr_blocks" {
  description = "List of cidr blocks of the EMR subnets"
  value       = compact(aws_subnet.emr[*].cidr_block)
}

output "emr_route_table_ids" {
  description = "List of IDs of the emr route table"
  value       = try(aws_route_table.emr[*].id, null)
}

output "emr_nat_gateway_route_ids" {
  description = "List of IDs of the emr nat gateway route"
  value       = try(aws_route.emr_nat[*].id, null)
}

output "emr_route_table_association_ids" {
  description = "List of IDs of the emr route talbe association"
  value       = aws_route_table_association.emr[*].id
}

# * NAT Gateway
output "nat_eip_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.this[*].id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.this[*].public_ip
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

# * Common
output "azs" {
  description = "List of Availability zones specified"
  value       = var.azs
}

output "name" {
  description = "The name of the VPC specificed"
  value       = var.name
}

