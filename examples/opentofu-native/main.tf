module "this" {
  source            = "../.."
  space_id          = "root"
  repository_name   = "demo"
  repository_branch = "main"
  name              = "my awesome native tofu stack"
  description       = "module test case for a native OpenTofu stack"
  tf_version        = "1.10.3"
  opentofu_native   = true
}
