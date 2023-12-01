resource "aws_vpc" "marlonsp_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "marlonsp-vpc"
  }

  enable_dns_hostnames = true
}

resource "aws_subnet" "marlonsp_public_subnet_1" {
  vpc_id                  = aws_vpc.marlonsp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "marlonsp_public_subnet_2" {
  vpc_id                  = aws_vpc.marlonsp_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "marlonsp_private_subnet_1" {
  vpc_id                  = aws_vpc.marlonsp_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "marlonsp_private_subnet_2" {
  vpc_id            = aws_vpc.marlonsp_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_internet_gateway" "marlonsp_igw" {
  vpc_id = aws_vpc.marlonsp_vpc.id

  tags = {
    Name = "marlonsp-igw"
  }
}

resource "aws_route_table" "marlonsp_public_route_table" {
  vpc_id = aws_vpc.marlonsp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.marlonsp_igw.id
  }

  tags = {
    Name = "marlonsp-public-route-table"
  }
}

resource "aws_route_table_association" "marlonsp_public_subnet_1_association" {
  subnet_id      = aws_subnet.marlonsp_public_subnet_1.id
  route_table_id = aws_route_table.marlonsp_public_route_table.id
}

resource "aws_route_table_association" "marlonsp_public_subnet_2_association" {
  subnet_id      = aws_subnet.marlonsp_public_subnet_2.id
  route_table_id = aws_route_table.marlonsp_public_route_table.id
}