terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
  shared_credentials_file = var.shared_credentials_file
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc main"
  cidr = var.vpc_cidr

  azs  = var.azs
  private_subnets = var.private_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false
  

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

#USERS

resource "aws_iam_user" "ec2_user"{
  name = "ec2_user"
  path = "/users/"
}

resource "aws_iam_user_group_membership" "ec2_user_share_s3"{
  user = aws_iam_user.ec2_user.name
  groups = [
    aws_iam_group.share_s3.name
  ]
}

#GROUP
resource "aws_iam_group" "share_s3"{
  name ="share_s3"
  path = "/" 
}

resource "aws_iam_group_policy_attachment" "assume_share_s3_role"{
  count = length(aws_iam_policy.assume_env_share_s3_role)
  group = aws_iam_group.share_s3.name
  policy_arn = element(aws_iam_policy.assume_env_share_s3_role.*.arn,count.index)
}

resource "aws_iam_policy" "assume_env_share_s3_role" {
  count       = length(var.aws_account_ids)
  name        = "assume_${element(keys(var.aws_account_ids), count.index)}_env_share_s3_role"
  path        = "/"
  description = "Allows assuming the share_s3_role role in the ${element(keys(var.aws_account_ids), count.index)} environment"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::${lookup(var.aws_account_ids, element(keys(var.aws_account_ids), count.index))}:role/share_s3"
    }
  ]
}
EOF
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-00ae935ce6c2aa534"
  instance_type = "t2.micro"

  tags = {
    Name = "TestEC2Instance"
  }
}
