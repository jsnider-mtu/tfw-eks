module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "sb"
  environment = var.env
  name        = "liberland"
  delimiter   = "-"
}
