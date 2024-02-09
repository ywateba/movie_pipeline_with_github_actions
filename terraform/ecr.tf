###################
# ECR Repositories
###################
resource "aws_ecr_repository" "frontend" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "ecr_access_role" {
    name = "EcrAccessRole"
    max_session_duration = 43200
    assume_role_policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Principal = {
            Service = "ecr.amazonaws.com"
          },
          Action = "sts:AssumeRole"
        },
        {
          Effect = "Allow",
          Principal = {

            AWS = "arn:aws:iam::470769016866:user/github-action-user"
          },
          Action = ["sts:AssumeRole","sts:TagSession"]
        }

      ]
    })
}

data "aws_iam_policy_document" "ecr_access_policy_document" {
  statement {
    effect = "Allow"
    sid    = "AllowPushPull"
    actions = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"

    ]

    resources = [
      aws_ecr_repository.backend.arn,
      aws_ecr_repository.frontend.arn

    ]
  }

  statement {
    effect = "Allow"
    sid    = "GetAuthorization"
    actions = [
          "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

}

resource "aws_iam_policy" "ecr_access_policy" {
    name = "EcrAccessPolicy"
    policy = data.aws_iam_policy_document.ecr_access_policy_document.json
}


resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  role       = aws_iam_role.ecr_access_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# resource "aws_iam_user_policy_attachment" "ecr_user_policy_attachment" {
#   user = aws_iam_user.github_action_user.name
#   policy_arn = aws_iam_policy.ecr_access_policy.arn
# }
