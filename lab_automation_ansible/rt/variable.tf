variable "vpc_id" {
  description = "ID of VPC"
  type        = string
}

variable "route" {
  description = "Route block configuration"
  type        = map(string)
}

variable "name" {
  description = "Route Table's name"
  type        = string
}