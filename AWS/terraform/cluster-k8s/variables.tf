variable "k8s_version" {
  type    = string
  default = "1.29.0"
}

variable "control_plane_count" {
  type    = number
  default = 2
}

variable "worker_count" {
  type    = number
  default = 2
}

variable "key_name" {
  type    = string
  default = "k8s-key"
}