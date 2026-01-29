
# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch subnets from default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "tls_private_key" "ssh_key" {
  count     = var.enable_ssh ? 1 : 0
  algorithm = "ED25519"
}

resource "aws_key_pair" "ssh_key" {
  count      = var.enable_ssh ? 1 : 0
  key_name   = "terra-ssh-key"
  public_key = tls_private_key.ssh_key[0].public_key_openssh
}
resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  role = aws_iam_role.ssm_role.name
}
resource "aws_security_group" "ec2_sg" {
  name        = "prod-ec2-sg"
  description = "Production EC2 SG"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.enable_ssh ? ["0.0.0.0/0"] : []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  subnet_id = data.aws_subnets.default.ids[0]

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  key_name = var.enable_ssh ? aws_key_pair.ssh_key[0].key_name : null

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = {
    Name        = var.instance_name
    Environment = "production"
    ManagedBy   = "Terraform"
  }

#  lifecycle {
#    prevent_destroy = true
#  }
}

