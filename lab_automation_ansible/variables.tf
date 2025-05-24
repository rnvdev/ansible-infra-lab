variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2 instances."
  type        = string
  default     = "ami-00874d747dde814fa"
}

variable "ec2_instance_type" {
  description = "Instance type for EC2 instances."
  type        = string
  default     = "t3.medium"
}

variable "availability_zone" {
  description = "Availability Zone for subnet and EC2 instances."
  type        = string
  default     = "us-east-1a"
}
