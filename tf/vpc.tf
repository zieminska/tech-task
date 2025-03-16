data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  azs_count     = 2
  azs_names     = ["eu-west-1a", "eu-west-1b"]
  vpc_cidr      = "10.0.0.0/16"
  public_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
}

resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr
  tags       = { Name = "${var.product_name}-vpc" }
}

resource "aws_subnet" "public" {
  count                   = local.azs_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_cidrs[count.index]
  availability_zone       = local.azs_names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = local.azs_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_cidrs[count.index]
  availability_zone = local.azs_names[count.index]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = local.azs_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}