# Project 1: Linux EC2 Web Server using Terraform

## Overview
This project provisions an Ubuntu EC2 web server on AWS using Terraform. Apache is installed automatically through a Bash user-data script.

## Technologies
- AWS EC2, VPC and Security Groups
- Terraform
- Ubuntu 24.04
- Bash and Apache

## AWS Region
Europe (Paris) – `eu-west-3`

## Infrastructure
- Custom VPC and public subnet
- Internet Gateway and route table
- Security Group (HTTP port 80)
- Ubuntu EC2 instance

## Deployment

```powershell
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Testing

Access the website using the public IP of the EC2 instance and verify that Apache serves the webpage.

## Cleanup

```powershell
terraform destroy
```