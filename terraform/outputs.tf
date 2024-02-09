output "frontend_ecr" {
  value = aws_ecr_repository.frontend.repository_url
}
output "backend_ecr" {
  value = aws_ecr_repository.backend.repository_url
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_version" {
  value = aws_eks_cluster.main.version
}

output "github_action_user_arn" {
  value = aws_iam_user.github_action_user.arn
}


output "ecr_access_role" {
  value = aws_iam_role.ecr_access_role.arn
}

output "eks_access_role" {
  value = aws_iam_role.eks_cluster_access_role
}

# Output the access key ID and secret (sensitive information)
output "access_key_id" {
  value = aws_iam_access_key.user_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.user_key.secret
  sensitive = true # Mark as sensitive to avoid exposing in logs
}