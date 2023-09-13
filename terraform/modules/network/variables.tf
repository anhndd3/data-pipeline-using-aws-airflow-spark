# * VPC
variable "azs" {
  description = ""
  type        = list(string)
  default     = []
}

variable "cidr_block" {
  description = ""
  type        = string
  default     = ""
}

variable "instance_tenancy" {
  description = ""
  type        = string
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = ""
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = ""
  type        = bool
  default     = true
}

variable "name" {
  description = ""
  type        = string
  default     = ""
}

variable "tags" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "enable_nat_gateway" {
  description = ""
  type        = bool
  default     = false
}

# * Public Subnets
variable "public_subnets" {
  description = ""
  type        = list(string)
  default     = null
}

variable "public_subnet_map_public_ip_on_launch" {
  description = ""
  type        = bool
  default     = true
}

variable "public_subnet_private_dns_hostname_type_on_launch" {
  description = ""
  type        = string
  default     = null
}

variable "public_subnet_tags" {
  description = ""
  type        = map(string)
  default     = {}
}

# * Private Subnets
variable "private_subnets" {
  description = ""
  type        = list(string)
  default     = null
}

variable "private_subnet_tags" {
  description = ""
  type        = map(string)
  default     = {}
}

# * Metadata Subnets
variable "metadata_subnets" {
  description = ""
  type        = list(string)
  default     = null
}

variable "create_metadata_subnet_group" {
  description = ""
  type        = bool
  default     = true
}

# * Database Subnets
variable "database_subnets" {
  description = ""
  type        = list(string)
  default     = null
}

variable "database_subnet_tags" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "create_database_subnet_group" {
  description = ""
  type        = bool
  default     = true
}

variable "database_subnet_group_name" {
  description = ""
  type        = string
  default     = null
}

# * Redshift Subnets
variable "redshift_subnets" {
  description = ""
  type        = list(string)
  default     = null
}

variable "redshift_subnet_tags" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "create_redshift_subnet_group" {
  description = ""
  type        = bool
  default     = true
}

variable "redshift_subnet_group_name" {
  description = ""
  type        = string
  default     = null
}

# * EMR Subnets
variable "emr_subnets" {
  description = ""
  type        = list(string)
  default     = null
}

variable "emr_subnet_tags" {
  description = ""
  type        = map(string)
  default     = {}
}
