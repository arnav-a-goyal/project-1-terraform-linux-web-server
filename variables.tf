
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "project-1-linux-web"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "use_existing_vpc" {
  description = "Reuse the default VPC and one of its public subnets instead of creating a VPC"
  type        = bool
  default     = true
}
