variable "vpc_cidr" {}
variable "vpc_name" {}
variable "cidr_public_subnet" {}
variable "US_AZs" {}
variable "cidr_private_subnet" {}

output "TF_Jenkins_VPC_id" {
  value = aws_vpc.TF_Jenkins_VPC.id
}

output "AWS_TF_Jen_public_subnets" {
  value = aws_subnet.AWS_TF_Jen_public_subnets.*.id
}

output "public_subnet_cidr_block" {
  value = aws_subnet.AWS_TF_Jen_public_subnets.*.cidr_block
}

# Setup VPC
resource "aws_vpc" "TF_Jenkins_VPC" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# Setup public subnet
resource "aws_subnet" "AWS_TF_Jen_public_subnets" {
  count             = length(var.cidr_public_subnet)
  vpc_id            = aws_vpc.TF_Jenkins_VPC.id
  cidr_block        = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.US_AZs, count.index)

  tags = {
    Name = "AWS_TF_Jenkins-public-subnet-${count.index + 1}"
  }
}

# Setup private subnet
resource "aws_subnet" "AWS_TF_Jen_private_subnets" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.TF_Jenkins_VPC.id
  cidr_block        = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.US_AZs, count.index)

  tags = {
    Name = "AWS_TF_Jenkins-private-subnet-${count.index + 1}"
  }
}

# Setup Internet Gateway
resource "aws_internet_gateway" "AWS_TF_Jen_pub_igw" {
  vpc_id = aws_vpc.TF_Jenkins_VPC.id
  tags = {
    Name = "AWS_TF_Jenkins-igw"
  }
}

# Public Route Table
resource "aws_route_table" "AWS_TF_Jen_pub_rt" {
  vpc_id = aws_vpc.TF_Jenkins_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.AWS_TF_Jen_pub_igw.id
  }
  tags = {
    Name = "AWS_TF_Jen_pub_rt"
  }
}

# Public Route Table and Public Subnet Association
resource "aws_route_table_association" "AWS_TF_Jen_public_rt_sn_assoc" {
  count          = length(aws_subnet.AWS_TF_Jen_public_subnets)
  subnet_id      = aws_subnet.AWS_TF_Jen_public_subnets[count.index].id
  route_table_id = aws_route_table.AWS_TF_Jen_pub_rt.id
}

# Private Route Table
resource "aws_route_table" "AWS_TF_Jen_priv_rt" {
  vpc_id = aws_vpc.TF_Jenkins_VPC.id
  #depends_on = [aws_nat_gateway.nat_gateway]
  tags = {
    Name = "AWS_TF_Jen_priv_rt"
  }
}

# Private Route Table and private Subnet Association
resource "aws_route_table_association" "AWS_TF_Jen_private_rt_sn_assoc" {
  count          = length(aws_subnet.AWS_TF_Jen_private_subnets)
  subnet_id      = aws_subnet.AWS_TF_Jen_private_subnets[count.index].id
  route_table_id = aws_route_table.AWS_TF_Jen_priv_rt.id
}
