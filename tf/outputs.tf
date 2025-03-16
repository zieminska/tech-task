output "repo_url" {
  value = aws_ecr_repository.ecr.repository_url
}

output "alb_dns" {
  value = aws_lb.alb.dns_name
}