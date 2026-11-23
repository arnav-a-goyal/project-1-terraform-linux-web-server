
# Project 1: Deploy Linux EC2 Web Server Using Terraform

## Objective

Deploy an Ubuntu Linux web server on AWS using Terraform and install Apache
automatically with an EC2 user-data Bash script.

## Technologies

- AWS EC2
- AWS VPC
- AWS Subnet
- AWS Internet Gateway
- AWS Security Group
- Terraform
- Ubuntu Linux
- Bash
- Apache
- Visual Studio Code

## Infrastructure

The configuration creates:

1. A VPC with DNS support
2. A public subnet
3. An Internet Gateway
4. A public route table and subnet association
5. A security group allowing HTTP on TCP port 80
6. An encrypted Ubuntu 24.04 EC2 instance
7. A public IPv4 address for the instance

By default, `use_existing_vpc` is `true` to support training AWS accounts that
have reached their regional VPC quota. In this mode Terraform reuses the
account's default VPC and an existing public subnet, but still creates and
manages the EC2 instance and web security group. Set
`use_existing_vpc = false` in `terraform.tfvars` when the account has capacity
and you want Terraform to create the VPC, subnet, Internet Gateway, and route
table.

SSH is intentionally not exposed because this project is managed through EC2
user data and only needs public web access.

## Prerequisites

- An AWS account
- AWS credentials with permission to manage EC2, VPC, security groups,
  subnets, Internet Gateways, route tables, and AMI lookups
- Terraform 1.5 or later
- AWS CLI

The default region is `ap-south-1` (Mumbai). To use another region, run Terraform
with `-var="aws_region=REGION"` or create a local `terraform.tfvars` file.

## Configure AWS Access

```powershell
aws configure
aws sts get-caller-identity
```

The first command prompts for the access key, secret key, default region, and
output format. The second command confirms that the selected credentials work.
Do not place credentials in Terraform files or commit them to GitHub.

## Deploy

Run the commands from the `project_1` directory:

```powershell
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Review the plan before applying it. The apply step creates AWS resources that
may incur charges.

After the apply finishes, Terraform prints the resource details. Retrieve the
website URL at any time with:

```powershell
terraform output website_url
```

## Apache Installation

`user_data.sh` runs automatically when Ubuntu boots. It:

1. Updates the package repository
2. Installs Apache
3. Writes the project webpage to `/var/www/html/index.html`
4. Enables and restarts the Apache service
5. Writes installation details to `/var/log/user-data.log`

Apache can take a few minutes to finish installing after the EC2 instance
becomes available.

## Testing

1. Run `terraform output website_url`.
2. Open the printed URL in a browser. Use `http://`, not `https://`.
3. Confirm that the page displays **Apache Web Server Successfully Deployed!**
4. If the page does not load immediately, wait two to three minutes and retry.

You can also verify connectivity from PowerShell:

```powershell
$websiteUrl = terraform output -raw website_url
Invoke-WebRequest $websiteUrl
```

## Evidence

Create an `evidence` folder and save:

1. A screenshot of the successful `terraform apply`, including the final
   `Apply complete! Resources: 4 added, 0 changed, 0 destroyed` message.
2. A screenshot of the AWS EC2 instance showing its name, instance ID, running
   state, public IP, VPC, subnet, and attached security group.
3. A browser screenshot of the `http://<public-ip>` webpage with the full
   address bar visible and the **Apache Web Server Successfully Deployed!**
   message.
4. A screenshot of `terraform output`, showing the matching instance ID,
   website URL, VPC ID, subnet ID, and security group ID.
5. An AWS Console screenshot of **EC2 > Security Groups > Inbound rules** for
   the Terraform security group. The screenshot must clearly show the only
   inbound rule is TCP port 80 from `0.0.0.0/0`, and that no port 22 (SSH) or
   port 3389 (RDP) rule exists.
6. A PowerShell screenshot of the following command and its JSON result:

```powershell
aws ec2 describe-security-groups `
  --group-ids (terraform output -raw security_group_id) `
  --query "SecurityGroups[0].{GroupId:GroupId,VpcId:VpcId,InboundRules:IpPermissions}" `
  --output json
```

7. A PowerShell screenshot confirming the application responds successfully:

```powershell
$url = terraform output -raw website_url
Invoke-WebRequest $url -UseBasicParsing
```

The Terraform configuration and deployed state intentionally expose HTTP port
80 only. Ports 22 and 3389 must never be added for trainer or trainee access.

Keep credentials, account identifiers that you do not want to publish, and
Terraform state files out of screenshots.

## Cleanup

After collecting the required evidence, remove all project resources:

```powershell
terraform destroy
```

Review the destroy plan and enter `yes` only when you are ready to permanently
remove the infrastructure.

## Publish to GitHub

1. Create an empty GitHub repository.
2. From the parent of this project, initialize and commit the project:

```powershell
git init
git add project_1
git commit -m "Add Terraform EC2 web server project"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
git push -u origin main
```

The included `.gitignore` excludes Terraform state, provider binaries, plans,
private keys, and local variable files. Submit the GitHub repository URL and
the saved webpage screenshot as the project deliverables.
