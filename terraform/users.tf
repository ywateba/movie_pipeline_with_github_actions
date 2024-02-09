

####################
# Github Action role
####################
resource "aws_iam_user" "github_action_user" {
  name = "github-action-user"
}

# Create access keys for the IAM user
resource "aws_iam_access_key" "user_key" {
  user = aws_iam_user.github_action_user.name
}



# resource "aws_iam_user_policy" "github_action_user_permission" {
#   user   = aws_iam_user.github_action_user.name
#   policy = data.aws_iam_policy_document.github_policy.json
# }

### too much privileges
# data "aws_iam_policy_document" "github_policy" {
#   statement {
#     effect    = "Allow"
#     actions   = ["ecr:*", "eks:*", "ec2:*"]
#     resources = ["*"]
#   }
# }


data "aws_iam_policy_document" "get_user_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["iam:GetUser"]
    resources = [aws_iam_user.github_action_user.arn]
  }

}

resource "aws_iam_policy" "get_user_policy" {
  name = "GetUserPolicy"
  policy = data.aws_iam_policy_document.get_user_policy_document.json
}


resource "aws_iam_role_policy_attachment" "get_ecr_user" {
  role = aws_iam_role.ecr_access_role.name
  policy_arn = aws_iam_policy.get_user_policy.arn

}


resource "aws_iam_role_policy_attachment" "get_eks_user" {
  role = aws_iam_role.eks_cluster_access_role.name
  policy_arn = aws_iam_policy.get_user_policy.arn

}






data "aws_iam_policy_document" "ecr_assume_role_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole","sts:TagSession"]
    resources = [aws_iam_role.ecr_access_role.arn]
  }

}

resource "aws_iam_policy" "ecr_assume_role_policy" {
  name = "EcrAccessAssumeRolePolicy"
  policy = data.aws_iam_policy_document.ecr_assume_role_policy_document.json

}

data "aws_iam_policy_document" "eks_assume_role_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole","sts:TagSession"]
    resources = [aws_iam_role.eks_cluster_access_role.arn]
  }

}

resource "aws_iam_policy" "eks_assume_role_policy" {
  name = "EksClusterAccessAssumeRolePolicy"
  policy = data.aws_iam_policy_document.eks_assume_role_policy_document.json

}



## Here we create a group for github action user with least privileges
## To ecr and EKS API
resource "aws_iam_group" "ecr_access_group" {
  name = "ecr_access_group"
}

resource "aws_iam_group" "eks_access_group" {
  name = "eks_cluster_access_group"
}


# #To assign permissions to group directly
resource "aws_iam_group_policy_attachment" "github_action_ecr" {
  group = aws_iam_group.ecr_access_group.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn

}

resource "aws_iam_group_policy_attachment" "github_action_eks" {
  group = aws_iam_group.eks_access_group.name
  policy_arn = aws_iam_policy.eks_cluster_access_policy.arn

}

resource "aws_iam_group_policy_attachment" "github_action_user" {
  group = aws_iam_group.ecr_access_group.name
  policy_arn = aws_iam_policy.get_user_policy.arn

}


# to allow group members to assume roles instead
# resource "aws_iam_group_policy_attachment" "ecr_access_group" {
#   group = aws_iam_group.ecr_access_group.name
#   policy_arn = aws_iam_policy.ecr_assume_role_policy.arn

# }


# resource "aws_iam_group_policy_attachment" "eks_access_group" {
#   group = aws_iam_group.eks_access_group.name
#   policy_arn = aws_iam_policy.eks_assume_role_policy.arn

# }



# Here we assign the github action user to the group
resource "aws_iam_group_membership" "github_action_ecr_group_membership" {
  name = "github_action_ecr_group_membership"

  users = [
    aws_iam_user.github_action_user.name,
  ]

  group = aws_iam_group.ecr_access_group.name

}

resource "aws_iam_group_membership" "github_action_eks_group_membership" {
  name = "github_action_eks_group_membership"

  users = [
    aws_iam_user.github_action_user.name,
  ]

  group = aws_iam_group.eks_access_group.name

}
