variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "enable_ssh" {
  description = "Enable SSH access (false in production)"
  type        = bool
  default     = false
}

variable "instance_name" {
  description = "EC2 Name tag"
  type        = string
}
variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
}

