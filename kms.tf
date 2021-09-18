module "kms_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context

  name = "liberland-secrets-kms"
}

data "aws_iam_policy_document" "kms" {
  statement {
    sid       = "0"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.liberland.arn]
    }
  }
}

resource "aws_kms_key" "kms" {
  description             = "Liberland EKS Secrets"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json

  tags = module.kms_label.tags
}
