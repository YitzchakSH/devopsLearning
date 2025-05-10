variable "security_group_name" {
  type    = string
  default = "k8s-ec2-sg"
}

variable "vpc_id" {
  type    = string
}
