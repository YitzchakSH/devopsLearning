output "vpc_id" {
  value = aws_vpc.k8s_vpc.id
}
output "subnet_id" {
  value = aws_subnet.k8s_subnet.id
}