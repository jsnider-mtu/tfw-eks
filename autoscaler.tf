module "as_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "autoscaler-role"
}

resource "aws_iam_role_policy" "autoscaler" {
  name = "autoscaler-policy"
  role = aws_iam_role.autoscaler.id

  policy =<<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
POLICY
}

resource "aws_iam_role" "autoscaler" {
  name = "autoscaler-role"

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
                    "oidc.eks.us-east-1.amazonaws.com/id/B719008E043C20632D48134D69534094:sub": "system:serviceaccount:autoscaler:autoscaler-sa"
                }
            }
        }
    ]
}
POLICY

  tags = module.as_label.tags
}
