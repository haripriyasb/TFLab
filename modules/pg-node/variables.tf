variable "name" {
  type        = string
  description = "Name of this node, used for the instance and its security group"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance size"
  default     = "t3.micro"
}

variable "availability_zone" {
  type        = string
  description = "Full AZ name to place the node in, for example us-west-2a"
}

variable "iam_instance_profile" {
  type        = string
  description = "Instance profile name that lets the node use SSM (IAM is global, so one profile works in every region)"
}

variable "user_data" {
  type        = string
  description = "Boot script contents"
}

variable "volume_size" {
  type        = number
  description = "Root disk size in GB"
}