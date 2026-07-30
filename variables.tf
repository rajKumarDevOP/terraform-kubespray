#====================================================================variables.tf========================================
variable "aws_region" {
  default = "ap-south-1"
}

variable "key_name" {
  description = "AWS Key Pair Name"
}


variable "subnet_id" {}

variable "masterCP_count" {
  default = 1
}
variable "gpu_worker_count" {
  default = 1
}
variable "admin_ips" {
  description = "CIDR block for SSH access"
  type        = list(string)
}
variable "master_instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "gpu_instance_type" {
  type    = string
  default = "t3a.medium"
}
variable "ami" {
  type = string

}
variable "security_group_id" {}
variable "private_key_path" {}