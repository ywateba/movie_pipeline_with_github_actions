

################
# EKS Resources
################
# Create an EKS cluster
resource "aws_eks_cluster" "main" {
  name     = "cluster"
  version  = var.k8s_version
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids              = [aws_subnet.private_subnet.id, aws_subnet.public_subnet.id]
    endpoint_public_access  = var.enable_private == true ? false : true
    endpoint_private_access = true
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster, aws_iam_role_policy_attachment.eks_service]
}


# Create an IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster" {
  name = "EksClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}



# Attach policies to the EKS cluster IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}


##################
# EKS Node Group
##################
# Track latest release for the given k8s version
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.main.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "main" {
  node_group_name = "udacity"
  cluster_name    = aws_eks_cluster.main.name
  version         = aws_eks_cluster.main.version
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [var.enable_private == true ? aws_subnet.private_subnet.id : aws_subnet.public_subnet.id]
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  instance_types  = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.node_group_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
  ]

  lifecycle {
    ignore_changes = [scaling_config.0.desired_size]
  }
}

// IAM Configuration
resource "aws_iam_role" "node_group" {
  name               = "udacity-node-group"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "node_group_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
## Codebuild not needed for this project

# ######################
# # CodeBuild Resources
# ######################
# # Create a CodeBuild project
# resource "aws_codebuild_project" "codebuild" {
#   name          = "udacity"
#   description   = "Udacity CodeBuild project"
#   service_role  = aws_iam_role.codebuild.arn
#   build_timeout = 60
#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:5.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"
#     privileged_mode             = true
#   }

#   source {
#     type            = "GITHUB"
#     location        = "https://github.com/your-org/your-repo"
#     git_clone_depth = 1
#     buildspec       = "buildspec.yml"
#   }

#   cache {
#     type = "NO_CACHE"
#   }
# }

# # Create the Codebuild Role
# resource "aws_iam_role" "codebuild" {
#   name = "codebuild-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "codebuild.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Attach the IAM policy to the codebuild role
# resource "aws_iam_role_policy_attachment" "codebuild" {
#   policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
#   role       = aws_iam_role.codebuild.name
# }


data "aws_iam_policy_document" "eks_cluster_role_assume_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.github_action_user.arn]
    }
  }
}

resource "aws_iam_role" "eks_cluster_access_role" {
  name = "EksClusterAccessRole"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_role_assume_policy_document.json
}

data "aws_iam_policy_document" "eks_cluster_access_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = [aws_eks_cluster.main.arn]
  }
}


resource "aws_iam_policy" "eks_cluster_access_policy" {
  name   = "EksClusterAccess"
  policy = data.aws_iam_policy_document.eks_cluster_access_policy_document.json

}


###  eks Admin policy

# resource "aws_iam_role" "eks_cluster_admin_role" {
#   name               = "EksClusterAdminRole"
#   assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy_document.json
# }

# data "aws_iam_policy_document" "eks_admin_assume_role_policy_document" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#     resources = [aws_iam_role.eks_cluster_admin_role.name]
#   }

# }








# resource "aws_iam_policy" "eks_admin_policy" {
#   name = "EksAdminPolicy"
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "eks:*"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : "iam:PassRole",
#         "Resource" : "*",
#         "Condition" : {
#           "StringEquals" : {
#             "iam:PassedToService" : "eks.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "eks_admin_assume_role_policy" {
#     name = "EksAdminAssumeRolePolicy"
#     policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "sts:AssumeRole"
#             ],
#             "Resource": "arn:aws:iam::424432388155:role/eks-admin"
#         }
#     ]
# })

# }

resource "aws_iam_role_policy_attachment" "eks_access_policy_attachment" {
  role       = aws_iam_role.eks_cluster_access_role.name
  policy_arn = aws_iam_policy.eks_cluster_access_policy.arn
}

# resource "aws_iam_role_policy_attachment" "eks_admin_policy_attachement" {
#   role       = aws_iam_role.eks_cluster_admin_role.name
#   policy_arn = aws_iam_policy.eks_admin_policy.arn
# }
