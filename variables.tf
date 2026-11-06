variable "region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "Name prefix for all resources"
  default     = "pg-lab"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance size"
  default     = "t3.micro"
}

variable "pg2_az" {
  type        = string
  description = "Availability zone for pg2, for example us-east-1b"
}


variable "dr_region" {
  type        = string
  description = "Second region, used by pg3"
}

variable "pg3_az" {
  type        = string
  description = "Availability zone for pg3; must be in dr_region, for example us-west-2a"
}

variable "pg2_volume_size" {
  type    = number
  
}

variable "pg3_volume_size" {
  type    = number
  
}