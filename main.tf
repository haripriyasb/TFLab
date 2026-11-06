# --- Look up existing things (data sources) ---

# Latest Ubuntu 24.04 image from Canonical
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Every new AWS account has a default VPC in each region
data "aws_vpc" "default" {
  default = true
}

# The default subnet in the "a" availability zone
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}a"
  default_for_az    = true
}

# --- IAM role so you can connect with SSM Session Manager (no SSH keys) ---

resource "aws_iam_role" "ec2_ssm" {
  name = "${var.name}-ec2-ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${var.name}-ec2-ssm"
  role = aws_iam_role.ec2_ssm.name
}

# --- Security group: no inbound at all, outbound open ---
# SSM works over outbound HTTPS, so nothing needs to be opened inbound.

resource "aws_security_group" "pg" {
  name        = "${var.name}-pg"
  description = "Postgres lab instance"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-pg"
  }
}

# --- The EC2 instance ---

resource "aws_instance" "pg" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.default.id
  vpc_security_group_ids = [aws_security_group.pg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm.name

  # Installs Postgres on first boot
  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  # Require IMDSv2 (security best practice)
  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name  = "${var.name}-pg1"
    Owner = "harip"
  }
}

module "pg2" {
  source = "./modules/pg-node"

  name                 = "${var.name}-pg2"
  instance_type        = var.instance_type
  availability_zone    = var.pg2_az
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name
  user_data            = file("${path.module}/user_data.sh")
  volume_size          = var.pg2_volume_size
}

module "pg3" {
  source = "./modules/pg-node"

  providers = {
    aws = aws.west
  }

  name                 = "${var.name}-pg3"
  instance_type        = var.instance_type
  availability_zone    = var.pg3_az
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name
  user_data            = file("${path.module}/user_data.sh")
  volume_size          = var.pg3_volume_size
  data_volume_size     = var.pg3_data_volume_size
}