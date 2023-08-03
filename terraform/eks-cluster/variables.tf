variable "region" {
  description = "AWS region"
  type        = string
}

variable "desired_capacity" {
  description = "Desired capacity of worker group"
  type        = number
}

variable "max_capacity" {
  description = "Maximum capacity of worker group"
  type        = number
}

variable "min_capacity" {
  description = "Minimum capacity of worker group"
  type        = number
}

variable "instance_type" {
  description = "Instance type of worker group"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH keypair to use in the cluster"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}