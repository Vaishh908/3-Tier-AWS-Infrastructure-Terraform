variable "name" {
  type = string
}

variable "tier" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "user_data" {
  type    = string
  default = null
}
