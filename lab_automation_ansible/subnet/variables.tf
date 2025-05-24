variable "vpc_id" {
  description = "VPC's ID"
  type        = string
}

variable "cidr_block" {
  description = "Subnet CIDR block"
  type        = string
}

variable "availability_zone" {
  description = "AZ where subnet must be deployed"
  type        = string
}

variable "name" {
  description = "Subnet's name"
  type        = string
}
