data "external" "get-ami-id" {
  program = ["bash", "${path.module}/scripts/get-ami-id.sh", var.k8s_version]
}