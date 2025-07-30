module "this" {
  source            = "../.."
  space_id          = "root"
  repository_name   = "demo"
  repository_branch = "main"
  name              = "my awesome tofu stack"
  description       = "module test case for an OpenTofu stack"
  tf_version        = "1.10.3"

}
