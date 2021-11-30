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

resource "aws_security_group" "efs" {
  name   = "efs-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    security_groups = [aws_eks_node_group.ondemand.resources[0].remote_access_security_group_id, aws_eks_node_group.spotone.resources[0].remote_access_security_group_id, aws_eks_node_group.spottwo.resources[0].remote_access_security_group_id]
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
  }

  egress {
    security_groups = [aws_eks_node_group.ondemand.resources[0].remote_access_security_group_id, aws_eks_node_group.spotone.resources[0].remote_access_security_group_id, aws_eks_node_group.spottwo.resources[0].remote_access_security_group_id]
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }
}

module "real_efs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-efs"
}

resource "aws_efs_file_system" "liberland" {
  creation_token = "liberland"

  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  tags = module.real_efs_label.tags
}

resource "aws_efs_backup_policy" "efs_backup" {
  file_system_id = aws_efs_file_system.liberland.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "a" {
  file_system_id  = aws_efs_file_system.liberland.id
  subnet_id       = aws_subnet.private-a.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "b" {
  file_system_id  = aws_efs_file_system.liberland.id
  subnet_id       = aws_subnet.private-b.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "c" {
  file_system_id  = aws_efs_file_system.liberland.id
  subnet_id       = aws_subnet.private-c.id
  security_groups = [aws_security_group.efs.id]
}

output "efs_dns" {
  value = aws_efs_file_system.liberland.dns_name
}

