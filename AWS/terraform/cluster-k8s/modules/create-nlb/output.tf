output "target_group_arn" {
  value = aws_lb_target_group.k8s_target_group.arn
}

output "control_plane_endpoint" {
  value = aws_lb.nlb.dns_name
}