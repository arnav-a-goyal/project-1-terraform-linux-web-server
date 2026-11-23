
locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }

  vpc_id    = var.use_existing_vpc ? data.aws_vpc.existing[0].id : aws_vpc.main[0].id
  subnet_id = var.use_existing_vpc ? data.aws_subnets.public[0].ids[0] : aws_subnet.public[0].id
}

# Find available Availability Zones

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "existing" {
  count   = var.use_existing_vpc ? 1 : 0
  default = true
}

data "aws_subnets" "public" {
  count = var.use_existing_vpc ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# Find the latest official Ubuntu 24.04 AMI

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 1. Create VPC

resource "aws_vpc" "main" {
  count                = var.use_existing_vpc ? 0 : 1
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

# 2. Create Internet Gateway

resource "aws_internet_gateway" "main" {
  count  = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.main[0].id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

# 3. Create Public Subnet

resource "aws_subnet" "public" {
  count                   = var.use_existing_vpc ? 0 : 1
  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet"
  })
}

# 4. Create Public Route Table

resource "aws_route_table" "public" {
  count  = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-route-table"
  })
}

# 5. Associate Route Table with Subnet

resource "aws_route_table_association" "public" {
  count          = var.use_existing_vpc ? 0 : 1
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}

# 6. Create Security Group

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP traffic to web server"
  vpc_id      = local.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-sg"
  })
}

# 7. Allow inbound HTTP traffic

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Allow public HTTP access"
}

# 8. Allow outbound traffic

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# 9. Create Ubuntu EC2 Instance

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id              = local.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]

  associate_public_ip_address = true

  # Install Apache automatically
  user_data = file("${path.module}/user_data.sh")

  # Replace EC2 when user data changes
  user_data_replace_on_change = true

  # Require IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Configure encrypted EBS storage
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-ec2"
  })

  depends_on = [
    aws_route_table_association.public,
    aws_vpc_security_group_ingress_rule.http,
    aws_vpc_security_group_egress_rule.all
  ]
}
