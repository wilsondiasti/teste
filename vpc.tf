# Configurando VPC
resource "aws_vpc" "vpc-desafio" {
  cidr_block = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "vpc-desafio"
  }
}

# Configurando Subnet Pública
resource "aws_subnet" "Public_subnet" {
  vpc_id                  = aws_vpc.vpc-desafio.id
  cidr_block              = var.publicsCIDRblock
  map_public_ip_on_launch = var.mapPublicIP 
  availability_zone       = var.availabilityZone
  tags = {
   Name = "subnet-publica"
  }
}
resource "aws_subnet" "Public_subnet2" {
  vpc_id                  = aws_vpc.vpc-desafio.id
  cidr_block              = var.publicsCIDRblockpublic2
  map_public_ip_on_launch = var.mapPublicIP 
  availability_zone       = var.availabilityZone2
  tags = {
   Name = "subnet-publica2"
  }
}

# Configurando Internet Gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.vpc-desafio.id
  tags = {
      Name = "IGW"
  }
}

# Configurando Tabela de Roteamento
resource "aws_route_table" "rtb_publico" {
  vpc_id = aws_vpc.vpc-desafio.id
  tags = {
      Name = "rtb_publico"
  }
}

# Configurando Roteador
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.rtb_publico.id
  destination_cidr_block = var.publicdestCIDRblock
  gateway_id             = aws_internet_gateway.IGW.id
}

# Configurando associação à tabela de roteamento
resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.Public_subnet.id
  route_table_id = aws_route_table.rtb_publico.id
}

# Configurando IP Externo para o IGW
resource "aws_eip" "ipwan" {
  	depends_on = [aws_internet_gateway.IGW]
  	vpc        = true
}

# Configurando NAT
resource "aws_nat_gateway" "GW" {
  allocation_id = aws_eip.ipwan.id
  subnet_id     = aws_subnet.Public_subnet.id
  depends_on    = [aws_internet_gateway.IGW]
}
# ======================================================================== #
# Configurando Subnet do Frontend
resource "aws_route_table" "rtb_priv_front" {
  vpc_id = aws_vpc.vpc-desafio.id
  tags = {
      Name = "rtb_priv_front"
  }
}
resource "aws_subnet" "subnet-privada_front" {
  vpc_id     = aws_vpc.vpc-desafio.id
  cidr_block = var.privatesCIDRblock_front
  tags       = {
      Name = "subnet-privada_front"
  }
}
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.subnet-privada_front.id
  route_table_id = aws_route_table.rtb_priv_front.id
}
resource "aws_route" "router-front" {
  route_table_id         = aws_route_table.rtb_priv_front.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.GW.id
  depends_on             = [aws_nat_gateway.GW]
}

# ======================================================================== #
# Configurando Subnet do Backend
resource "aws_route_table" "rtb_priv_back" {
  vpc_id = aws_vpc.vpc-desafio.id
  tags = {
      Name = "rtb_priv_back"
  }
}

resource "aws_subnet" "subnet-privada_back" {
  vpc_id     = aws_vpc.vpc-desafio.id
  cidr_block = var.privatesCIDRblock_back
  tags       = {
      Name = "subnet-privada_back"
  }
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.subnet-privada_back.id
  route_table_id = aws_route_table.rtb_priv_back.id
}

resource "aws_route" "router-back" {
  route_table_id         = aws_route_table.rtb_priv_back.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.GW.id
  depends_on             = [aws_nat_gateway.GW]
}

# ======================================================================== #

# Configurando Subnet do DB
resource "aws_subnet" "subnet-privada_db" {
  vpc_id     = aws_vpc.vpc-desafio.id
  cidr_block = var.privatesCIDRblock_db
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-privada_db"
  }
}
resource "aws_subnet" "subnet-privada_db2" {
  vpc_id     = aws_vpc.vpc-desafio.id
  cidr_block = "1.2.7.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet-privada_db2"
  }
}
resource "aws_db_subnet_group" "db_subnet_grp" {
  name = "dbsubnetgrp"
  subnet_ids = [aws_subnet.subnet-privada_db.id, aws_subnet.subnet-privada_db2.id]
}