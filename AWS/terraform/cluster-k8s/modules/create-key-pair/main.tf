resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = tls_private_key.generated.public_key_openssh
}

resource "local_file" "save_private_key" {
  content              = tls_private_key.generated.private_key_pem
  filename             = "${path.module}/../../files/${var.key_name}.pem" # adjust path as needed
  file_permission      = "0600"
  directory_permission = "0700"
}