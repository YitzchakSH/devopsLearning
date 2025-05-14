output "id" {
  value = data.external.get-ami-id.result["ami_id"]
}