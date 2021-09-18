module "vpc_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-vpc"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = module.vpc_label.tags
}

module "igw_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-igw"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = module.igw_label.tags
}

module "sn_pr_a_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-subnet-private-a"

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.liberland.name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = module.sn_pr_a_label.tags
}

module "sn_pr_b_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-subnet-private-b"

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.liberland.name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = module.sn_pr_b_label.tags
}

module "sn_pr_c_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-subnet-private-c"

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.liberland.name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private-c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1c"

  tags = module.sn_pr_c_label.tags
}

module "sn_pu_a_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-subnet-public-a"

  tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = module.sn_pu_a_label.tags
}

module "sn_pu_b_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-subnet-public-b"

  tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = module.sn_pu_b_label.tags
}

module "sn_pu_c_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-subnet-public-c"

  tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public-c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1c"

  tags = module.sn_pu_c_label.tags
}

module "rt_pu_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-rt-public"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = module.rt_pu_label.tags
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-c" {
  subnet_id      = aws_subnet.public-c.id
  route_table_id = aws_route_table.public.id
}

module "ngw_eip_a_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-ngw-eip-a"
}

resource "aws_eip" "ngw-a" {
  vpc = true

  tags = module.ngw_eip_a_label.tags

  depends_on = [aws_internet_gateway.igw]
}

module "ngw_eip_b_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-ngw-eip-b"
}

resource "aws_eip" "ngw-b" {
  vpc = true

  tags = module.ngw_eip_b_label.tags

  depends_on = [aws_internet_gateway.igw]
}

module "ngw_eip_c_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-ngw-eip-c"
}

resource "aws_eip" "ngw-c" {
  vpc = true

  tags = module.ngw_eip_c_label.tags

  depends_on = [aws_internet_gateway.igw]
}

module "ngw_a_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-ngw-a"
}

resource "aws_nat_gateway" "a" {
  allocation_id = aws_eip.ngw-a.id
  subnet_id     = aws_subnet.public-a.id

  tags = module.ngw_a_label.tags
}

module "ngw_b_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-ngw-b"
}

resource "aws_nat_gateway" "b" {
  allocation_id = aws_eip.ngw-b.id
  subnet_id     = aws_subnet.public-b.id

  tags = module.ngw_b_label.tags
}

module "ngw_c_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-ngw-c"
}

resource "aws_nat_gateway" "c" {
  allocation_id = aws_eip.ngw-c.id
  subnet_id     = aws_subnet.public-c.id

  tags = module.ngw_c_label.tags
}

module "rt_pr_a_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-rt-private-a"
}

resource "aws_route_table" "private-a" {
  vpc_id = aws_vpc.vpc.id

  tags = module.rt_pr_a_label.tags
}

resource "aws_route" "ngw-a" {
  route_table_id         = aws_route_table.private-a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.a.id
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private-a.id
}

module "rt_pr_b_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-rt-private-b"
}

resource "aws_route_table" "private-b" {
  vpc_id = aws_vpc.vpc.id

  tags = module.rt_pr_b_label.tags
}

resource "aws_route" "ngw-b" {
  route_table_id         = aws_route_table.private-b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.b.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private-b.id
}

module "rt_pr_c_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-rt-private-c"
}

resource "aws_route_table" "private-c" {
  vpc_id = aws_vpc.vpc.id

  tags = module.rt_pr_c_label.tags
}

resource "aws_route" "ngw-c" {
  route_table_id         = aws_route_table.private-c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.c.id
}

resource "aws_route_table_association" "private-c" {
  subnet_id      = aws_subnet.private-c.id
  route_table_id = aws_route_table.private-c.id
}

