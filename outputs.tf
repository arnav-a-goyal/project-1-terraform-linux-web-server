output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS"
  value       = aws_instance.web.public_dns
}

output "website_url" {
  description = "Website URL"
  value       = "http://${aws_instance.web.public_ip}"
}

output "vpc_id" {
  description = "New VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.web.id
}

output "ubuntu_ami_id" {
  description = "Ubuntu AMI ID"
  value       = data.aws_ami.ubuntu.id
}