output "key_name" {
  value = aws_key_pair.this.key_name
}

output "private_key_pem" {
  value     = tls_private_key.generated.private_key_pem
  sensitive = true
}

output "private_key_path" {
  value = abspath(local_file.save_private_key.filename)
}