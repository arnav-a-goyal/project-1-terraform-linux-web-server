variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Project resource naming prefix"
  type        = string
  default     = "project-1-linux-web"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}