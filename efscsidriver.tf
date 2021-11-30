module "efs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "efs-csi-driver-role"
}

resource "aws_iam_role_policy" "efs-csi-driver" {
  name = "efs-csi-driver-policy"
  role = aws_iam_role.efs-csi-driver.id

  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role" "efs-csi-driver" {
  name = "efs-csi-driver-role"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "0",
            "Effect": "Allow",
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Principal": {
                "Federated": "arn:aws:iam::556005419303:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/B719008E043C20632D48134D69534094"
            },
            "Condition": {
                "StringEquals": {
                    "oidc.eks.us-east-1.amazonaws.com/id/B719008E043C20632D48134D69534094:sub": "system:serviceaccount:kube-system:efs-csi-driver-sa"
                }
            }
        }
    ]
}
POLICY

  tags = module.efs_label.tags
}
