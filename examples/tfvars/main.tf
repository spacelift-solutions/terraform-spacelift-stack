module "this" {
  source            = "../.."
  space_id          = "root"
  repository_name   = "demo"
  repository_branch = "main"
  name              = "my awesome tfvars stack"
  description       = "module test case for a stack with a variable file"
  tf_vars           = "environments/production.tfvars"

}
