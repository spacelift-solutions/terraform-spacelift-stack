module "this" {
  source            = "../.."
  space_id          = "root"
  repository_name   = "demo"
  repository_branch = "main"
  name              = "my awesome terragrunt stack"
  description       = "module test case for a native Terragrunt stack"
  workflow_tool     = "TERRAGRUNT"

  terragrunt_config = {
    terraform_version                      = "1.8.1"
    terragrunt_version                     = "0.66.3"
    tool                                   = "OPEN_TOFU"
    use_run_all                            = true
    use_smart_sanitation                   = true
    prefix_resource_names_with_module_name = true
    skip_replan                            = false
  }

}
