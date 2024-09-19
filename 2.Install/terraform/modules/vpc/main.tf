#################
# VPC
#################

resource "aws_vpc" "this" {
  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}


#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.private_subnets[count.index]
  availability_zone               = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_subnet_suffix}-%s",
        var.name,
        count.index+1,
      )
    },
    var.tags,
    var.private_subnet_tags,
  )
}

#################
# Public subnet
#################
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.public_subnets[count.index]
  availability_zone               = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-${var.public_subnet_suffix}-%s",
        var.name,
        count.index+1,
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
}

#################
# IGW
#################

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.name}-IGW"},
    var.tags,
    var.igw_tags,
  )
}

#################
# NAT
#################

resource "aws_eip" "nat" {

  tags = merge(
    {
      "Name" = "${var.name}-NAT"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}


resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id

  tags = merge(
    {
      "Name" ="${var.name}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

#################
# Public Routes
#################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.name}-${var.public_subnet_suffix}"
    },
    var.tags
  )
}


resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route" "public_internet_gateway" {

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

#################
# Private Routes
#################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      "Name" = "${var.name}-${var.private_subnet_suffix}"
    },
    var.tags,
  )
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.this.id

  timeouts {
    create = "5m"
  }
}