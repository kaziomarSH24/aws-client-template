variable "aws_region" {
  description = "AWS Region to deploy resources (e.g., ap-southeast-1, us-east-1)"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name, used for tagging resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance type (e.g., t3.small, t3.medium)"
  type        = string
  default     = "t3.small"
}

variable "volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 30
}

variable "public_key_path" {
  description = "Path to the local public SSH key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "allowed_ssh_ips" {
  description = "List of IP addresses allowed to SSH into the server"
  type        = list(string)
}