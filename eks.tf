resource "aws_iam_role" "liberland" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.liberland.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.liberland.name
}

module "eks_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-eks-cluster"
}

resource "aws_eks_cluster" "liberland" {
  name     = "liberland"
  role_arn = aws_iam_role.liberland.arn

  encryption_config {
    provider {
      key_arn = aws_kms_key.kms.arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    subnet_ids = [aws_subnet.private-a.id, aws_subnet.private-b.id, aws_subnet.private-c.id]
  }

  tags = module.eks_label.tags

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}

data "tls_certificate" "cert" {
  url = aws_eks_cluster.liberland.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "liberland" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.liberland.identity[0].oidc[0].issuer
}
