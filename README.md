# aws-terraform

This is a terraform project created to deploy AWS services to meet the objectives highlighted below:

Objectives:

* An S3 bucket provisioned on an AWS account (Account 1) (mainAccount)
* A custom VPC with a private subnet on a seperate account (Account 2) (externalAccount)
* On Account 2; An EC2 instance provisioned within the private subnet with direct access to the S3 bucket provisioned on Account 1.

The are two terraform scripts each runs the from the different account folder "mainAccount/externalAccount" 

mainAccount: The main account provisions the EC2 instance in a vpc network with a private subnet, and creates a user group with an Aws IAM role sharing policy for communicating with resources in account 2 (externalAccount). The terraform script also initiates a connection with the AWS Session manager allowing access to the EC2 from AWS CLI and session tools. The terraform scripts here also contains a s3 bucket provisioned to save the terraform state.

externalAccount: The external account provisions the s3 buckets and assigns the access policy.

Running:
Terraform basic commands:
terraform init
terraform plan -var-file="var.tfvar"
terraform apply -var-file="var.tfvar"
