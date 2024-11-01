locals {
  is_tf_tool        = var.workflow_tool == "OPEN_TOFU" || var.workflow_tool == "TERRAFORM_FOSS"
  is_terragrunt     = var.workflow_tool == "TERRAGRUNT"
  is_cloudformation = var.workflow_tool == "CLOUDFORMATION"
}

resource "spacelift_stack" "this" {
  name                     = var.name
  repository               = var.repository_name
  branch                   = var.repository_branch
  description              = var.description
  terraform_version        = local.is_tf_tool ? var.tf_version : null
  worker_pool_id           = var.worker_pool_id
  project_root             = var.project_root
  labels                   = var.labels
  enable_local_preview     = true
  autodeploy               = var.auto_deploy
  manage_state             = var.manage_state
  terraform_workflow_tool  = local.is_tf_tool ? var.workflow_tool : null
  space_id                 = var.space_id
  runner_image             = var.runner_image
  github_action_deploy     = var.allow_promotion
  terraform_workspace      = var.tf_workspace
  additional_project_globs = var.additional_project_globs

  administrative = var.administrative

  terraform_smart_sanitization = true

  dynamic "terragrunt" {
    for_each = local.is_terragrunt ? ["TERRAGRUNT"] : []

    content {
      terragrunt_version     = var.terragrunt_config.terragrunt_version
      terraform_version      = var.terragrunt_config.terraform_version
      use_run_all            = var.terragrunt_config.use_run_all
      use_smart_sanitization = var.terragrunt_config.use_smart_sanitation
      tool                   = var.terragrunt_config.tool
    }
  }

  dynamic "bitbucket_cloud" {
    for_each = var.vcs_integration == "BITBUCKET" ? ["BITBUCKET"] : []

    content {
      namespace = var.bitbucket_cloud_namespace
    }
  }

  dynamic "cloudformation" {
    for_each = local.is_cloudformation ? ["CLOUDFORMATION"] : []

    content {
      stack_name          = var.cloudformation.stack_name
      entry_template_file = var.cloudformation.entry_template_file
      region              = var.cloudformation.region
      template_bucket     = var.cloudformation.template_bucket
    }
  }
}

resource "spacelift_aws_integration_attachment" "this" {
  count = var.aws_integration.enabled ? 1 : 0

  integration_id = var.aws_integration.id
  stack_id       = spacelift_stack.this.id
  read           = true
  write          = true
}

resource "spacelift_environment_variable" "this" {
  for_each = var.environment_variables

  stack_id   = spacelift_stack.this.id
  name       = each.key
  value      = each.value.value
  write_only = each.value.sensitive
}

resource "spacelift_policy" "this" {
  for_each = var.policies

  name = each.key
  body = file(each.value.file_path)
  type = each.value.type

  space_id = var.space_id
}

resource "spacelift_policy_attachment" "this" {
  for_each = var.policies

  policy_id = spacelift_policy.this[each.key].id
  stack_id  = spacelift_stack.this.id
}

locals {
  references_list = flatten([
    for key, value in var.dependencies : [
      for reference_key, reference in value.references : {
        reference_key       = reference_key
        stack_dependency_id = key
        input_name          = reference.input_name
        output_name         = reference.output_name
        trigger_always      = coalesce(reference.trigger_always, false)
      }
    ] if value.references != null
  ])

  references = {
    for key, reference in local.references_list : "${reference.stack_dependency_id}_${reference.reference_key}" => reference
  }
}

resource "spacelift_stack_dependency" "this" {
  for_each = var.dependencies

  stack_id            = each.value.dependent_stack_id
  depends_on_stack_id = spacelift_stack.this.id
}

resource "spacelift_stack_dependency_reference" "this" {
  for_each = local.references

  stack_dependency_id = spacelift_stack_dependency.this[each.value.stack_dependency_id].id
  input_name          = each.value.input_name
  output_name         = each.value.output_name
  trigger_always      = each.value.trigger_always
}