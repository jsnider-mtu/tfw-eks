module "ng_od_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-ondemand-node-group"
}

module "ng_so_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-spotone-node-group"
}

module "ng_st_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-spottwo-node-group"
}

resource "aws_iam_role" "node-role" {
  name = "liberland-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role.name
}

resource "aws_eks_node_group" "ondemand" {
  cluster_name    = aws_eks_cluster.liberland.name
  node_group_name = "liberland-ondemand-node-group"
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = [aws_subnet.private-a.id, aws_subnet.private-b.id, aws_subnet.private-c.id]

  instance_types = ["t3a.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  remote_access {
    ec2_ssh_key = "id_rsa"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = module.ng_od_label.tags

  labels = {"lifecycle" = "ondemand"}

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "spotone" {
  cluster_name    = aws_eks_cluster.liberland.name
  node_group_name = "liberland-spotone-node-group"
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = [aws_subnet.private-a.id, aws_subnet.private-b.id, aws_subnet.private-c.id]

  instance_types = ["m5.xlarge", "m5n.xlarge", "m5d.xlarge", "m5dn.xlarge","m5a.xlarge", "m4.xlarge"]

  capacity_type = "SPOT"

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  remote_access {
    ec2_ssh_key = "id_rsa"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = module.ng_so_label.tags

  labels = {"lifecycle" = "spot"}

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "spottwo" {
  cluster_name    = aws_eks_cluster.liberland.name
  node_group_name = "liberland-spottwo-node-group"
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = [aws_subnet.private-a.id, aws_subnet.private-b.id, aws_subnet.private-c.id]

  instance_types = ["m5.2xlarge", "m5n.2xlarge", "m5d.2xlarge", "m5dn.2xlarge","m5a.2xlarge", "m4.2xlarge"]

  capacity_type = "SPOT"

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  remote_access {
    ec2_ssh_key = "id_rsa"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = module.ng_st_label.tags

  labels = {"lifecycle" = "spot"}

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

