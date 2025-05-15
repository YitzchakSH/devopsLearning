variable "ami" {
  type    = string
}

variable "control_plane_count" {
  type    = number
}

variable "worker_count" {
  type    = number
}

variable "subnet_id" {
  type    = string
}

variable "security_group_id" {
  type    = string
}

variable "key_name" {
  type    = string
}

variable "private_key_path" {
  type    = string
}

variable "k8s_version" {
  type    = string
}