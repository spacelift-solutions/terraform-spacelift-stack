module "this" {
  source            = "../.."
  space_id          = "root"
  repository_name   = "demo"
  repository_branch = "main"
  project_root      = "kubernetes/aws"
  name              = "my awesome kube stack"
  description       = "module test case for a Kubernetes stack"
  workflow_tool     = "KUBERNETES"

}
