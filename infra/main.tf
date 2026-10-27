terraform {
  required_version = ">= 1.6, < 2.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}
provider "aws" { region = var.region }
variable "region" { default = "ap-south-1" }
variable "instance_type" { default = "t3.micro" }
variable "lab_name" {
  default = "darsh-devops"
  validation {
    condition = can(regex("^[a-z][a-z0-9-]{2,24}$", var.lab_name))
    error_message = "Use 3-25 lowercase letters, digits and hyphens; start with a letter."
  }
}
resource "aws_vpc" "lab" {
  cidr_block = "10.42.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = { Name = var.lab_name }
}
resource "aws_subnet" "lab" {
  vpc_id = aws_vpc.lab.id
  cidr_block = "10.42.1.0/24"
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "lab" { vpc_id = aws_vpc.lab.id }
resource "aws_route_table" "lab" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }
}
resource "aws_route_table_association" "lab" {
  subnet_id = aws_subnet.lab.id
  route_table_id = aws_route_table.lab.id
}
# No inbound ports. Access the demo through an SSM session/port forwarding.
resource "aws_security_group" "lab" {
  name_prefix = "${var.lab_name}-"
  vpc_id = aws_vpc.lab.id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_iam_role" "ec2" {
  name_prefix = "${var.lab_name}-"
  assume_role_policy = jsonencode({Version = "2012-10-17", Statement = [{
    Effect = "Allow", Principal = {Service = "ec2.amazonaws.com"}, Action = "sts:AssumeRole"
  }]})
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "lab" { role = aws_iam_role.ec2.name }
resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${var.lab_name}-"
  force_destroy = false
}
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_iam_role_policy" "artifact_read" {
  role = aws_iam_role.ec2.id
  policy = jsonencode({Version = "2012-10-17", Statement = [{Effect = "Allow",
    Action = ["s3:GetObject"], Resource = "${aws_s3_bucket.artifacts.arn}/*"}]})
}
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
resource "aws_instance" "lab" {
  ami = data.aws_ssm_parameter.ami.value
  instance_type = var.instance_type
  subnet_id = aws_subnet.lab.id
  vpc_security_group_ids = [aws_security_group.lab.id]
  iam_instance_profile = aws_iam_instance_profile.lab.name
  metadata_options { http_tokens = "required" }
  root_block_device {
    encrypted = true
    volume_size = 8
    volume_type = "gp3"
  }
  user_data = file("${path.module}/bootstrap.sh")
  user_data_replace_on_change = true
  tags = { Name = var.lab_name }
  depends_on = [aws_route_table_association.lab, aws_iam_role_policy_attachment.ssm]
}
output "instance_id" { value = aws_instance.lab.id }
output "artifact_bucket" { value = aws_s3_bucket.artifacts.id }
