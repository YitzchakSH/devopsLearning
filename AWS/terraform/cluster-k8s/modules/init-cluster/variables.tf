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