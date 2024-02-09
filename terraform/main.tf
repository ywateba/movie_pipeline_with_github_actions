####################
# VPC Configuration
####################
# Create a VPC
resource "aws_vpc" "vpc" {
  tags = {
    "Name" = "udacity"
  }
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1${var.public_az}"
  map_public_ip_on_launch = true
  tags = {
    Name = "udacity-public"
  }
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

# Associate the route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1${var.private_az}"
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "udacity-private"
  }
}

# Create private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private"
  }
}

# Associate private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

# Create EKS endpoint for private access
resource "aws_vpc_endpoint" "eks" {
  count               = var.enable_private == true ? 1 : 0 # only enable when private
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.eks"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_eks_cluster.main.vpc_config.0.cluster_security_group_id]
  subnet_ids          = [aws_subnet.private_subnet.id]
  private_dns_enabled = true
}


# Create EC2 endpoint for private access
resource "aws_vpc_endpoint" "ec2" {
  count               = var.enable_private == true ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_eks_cluster.main.vpc_config.0.cluster_security_group_id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr-dkr-endpoint" {
  count               = var.enable_private == true ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_eks_cluster.main.vpc_config.0.cluster_security_group_id]
  subnet_ids          = [aws_subnet.private_subnet.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr-api-endpoint" {
  count               = var.enable_private == true ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_eks_cluster.main.vpc_config.0.cluster_security_group_id]
  subnet_ids          = [aws_subnet.private_subnet.id]
  private_dns_enabled = true
}
