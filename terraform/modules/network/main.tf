locals {
  len_public_subnets   = length(var.public_subnets != null ? var.public_subnets : [])
  len_private_subnets  = length(var.private_subnets != null ? var.private_subnets : [])
  len_metadata_subnets = length(var.metadata_subnets != null ? var.metadata_subnets : [])
  len_redshift_subnets = length(var.redshift_subnets != null ? var.redshift_subnets : [])
  len_database_subnets = length(var.database_subnets != null ? var.database_subnets : [])
  len_emr_subnets      = length(var.emr_subnets != null ? var.emr_subnets : [])
}

data "aws_region" "this" {}

# * VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = try(var.name, "")
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${try(var.name, "")}-igw"
    }
  )
}

resource "aws_eip" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    { Name = "${var.name}-eip" }
  )
  depends_on = [aws_internet_gateway.this]
}

# * Public subnets
resource "aws_subnet" "public" {
  count = local.len_public_subnets != 0 ? local.len_public_subnets : 0

  vpc_id                  = aws_vpc.this.id
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block              = element(var.public_subnets, count.index)
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch

  tags = merge(
    var.tags,
    try(var.public_subnet_tags, {}),
    { Name = format("${var.name}-${var.azs[count.index]}-public-subnet") }
  )
}

resource "aws_route_table" "public" {
  count = local.len_public_subnets > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.name}-public-rtb" }
  )
}

resource "aws_route_table_association" "public" {
  count = local.len_public_subnets > 0 ? local.len_public_subnets : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route" "public_internet_gateway" {
  count = local.len_public_subnets > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.tags,
    { Name = "${var.name}-nat" }
  )

  depends_on = [aws_subnet.public, aws_internet_gateway.this, aws_eip.this]
}

# * Private subnets
resource "aws_subnet" "private" {
  count = local.len_private_subnets != 0 ? local.len_private_subnets : 0

  vpc_id               = aws_vpc.this.id
  availability_zone    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block           = element(var.private_subnets, count.index)

  tags = merge(
    var.tags,
    var.private_subnet_tags,
    { Name = "${var.name}-${var.azs[count.index]}-private-subnet" }
  )
}

resource "aws_route_table" "private" {
  count = local.len_private_subnets > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.name}-private-rtb" }
  )
}

resource "aws_route_table_association" "private" {
  count = local.len_private_subnets > 0 ? local.len_private_subnets : 0

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
  timeouts {
    create = "5m"
  }
}

# * Metadata subnets
resource "aws_subnet" "metadata" {
  count = local.len_metadata_subnets > 0 ? local.len_metadata_subnets : 0

  vpc_id               = aws_vpc.this.id
  availability_zone    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block           = element(var.metadata_subnets, count.index)

  tags = merge(
    var.tags,
    { Name = "${var.name}-metadata-subnet" }
  )
}

resource "aws_db_subnet_group" "metadata" {
  count = local.len_metadata_subnets > 0 && var.create_metadata_subnet_group ? 1 : 0

  name       = "metadata-subnet-group"
  subnet_ids = aws_subnet.metadata[*].id

  tags = merge(
    var.tags,
    { Name = "${var.name}-metadata-subnet-group" }
  )
}

resource "aws_route_table" "metadata" {
  count = local.len_metadata_subnets > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.name}-metadata-rtb" }
  )
}

resource "aws_route_table_association" "metadata" {
  count = local.len_metadata_subnets > 0 ? local.len_metadata_subnets : 0

  subnet_id      = element(aws_subnet.metadata[*].id, count.index)
  route_table_id = aws_route_table.metadata[0].id
}

# * Database subnets
resource "aws_subnet" "database" {
  count = local.len_database_subnets > 0 ? local.len_database_subnets : 0

  vpc_id               = aws_vpc.this.id
  availability_zone    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block           = element(var.database_subnets, count.index)

  tags = merge(
    var.tags,
    var.database_subnet_tags,
    { Name = "${var.name}-${var.azs[count.index]}-database-subnet" }
  )
}

resource "aws_db_subnet_group" "database" {
  count = local.len_database_subnets > 0 && var.create_database_subnet_group ? 1 : 0

  name       = try(var.database_subnet_group_name, "${var.name}-database-subnet-group")
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.tags,
    var.database_subnet_tags,
    { Name = "${var.name}-database-subnet-group" }
  )
}

resource "aws_route_table" "database" {
  count = local.len_database_subnets > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.database_subnet_tags,
    { Name = "${var.name}-database-rtb" }
  )
}

resource "aws_route" "database_nat" {
  count = var.enable_nat_gateway && local.len_database_subnets > 0 ? 1 : 0

  route_table_id         = aws_route_table.database[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "database" {
  count = var.enable_nat_gateway && local.len_database_subnets > 0 ? local.len_database_subnets : 0

  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database[0].id
}

# * Redshift subnets
resource "aws_subnet" "redshift" {
  count = local.len_redshift_subnets > 0 ? local.len_redshift_subnets : 0

  vpc_id               = aws_vpc.this.id
  availability_zone    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block           = element(var.redshift_subnets, count.index)

  tags = merge(
    var.tags,
    var.redshift_subnet_tags,
    { Name = "${var.name}-${var.azs[count.index]}-redshift-subnet" }
  )
}

resource "aws_db_subnet_group" "redshift" {
  count = local.len_redshift_subnets > 0 && var.create_redshift_subnet_group ? 1 : 0

  name       = try(var.redshift_subnet_group_name, "${var.name}-redshift-subnet-group")
  subnet_ids = aws_subnet.redshift[*].id

  tags = merge(
    var.tags,
    var.redshift_subnet_tags,
    { Name = "${var.name}-redshift-subnet-group" }
  )
}

resource "aws_route_table" "redshift" {
  count = local.len_redshift_subnets > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.redshift_subnet_tags,
    { Name = "${var.name}-redshift-rtb" }
  )
}

resource "aws_route_table_association" "redshift" {
  count = local.len_redshift_subnets > 0 ? local.len_redshift_subnets : 0

  subnet_id      = element(aws_subnet.redshift[*].id, count.index)
  route_table_id = aws_route_table.redshift[0].id
}

# * EMR subnets
resource "aws_subnet" "emr" {
  count = local.len_emr_subnets > 0 ? local.len_emr_subnets : 0

  vpc_id               = aws_vpc.this.id
  availability_zone    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  cidr_block           = element(var.emr_subnets, count.index)

  tags = merge(
    var.tags,
    var.emr_subnet_tags,
    { Name = "${var.name}-${var.azs[count.index]}-emr-subnet" }
  )
}

resource "aws_route_table" "emr" {
  count = local.len_emr_subnets > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.emr_subnet_tags,
    { Name = "${var.name}-emr-rtb" }
  )
}

resource "aws_route_table_association" "emr" {
  count          = local.len_emr_subnets > 0 ? local.len_emr_subnets : 0
  subnet_id      = element(aws_subnet.emr[*].id, count.index)
  route_table_id = aws_route_table.emr[0].id
}

resource "aws_route" "emr_nat" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.emr[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
  timeouts {
    create = "5m"
  }
}
