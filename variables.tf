variable "additional_project_globs" {
  type        = list(string)
  description = "Additional project globs to add to the stack."
  default     = []
}

variable "administrative" {
  type        = bool
  description = "Whether the stack is administrative or not."
  default     = false
}

variable "allow_promotion" {
  type        = bool
  description = "Whether to allow promotion of the stack to the next environment."
  default     = true
}

variable "auto_deploy" {
  type        = bool
  description = "Whether to auto deploy the stack."
  default     = false
}

variable "aws_integration" {
  type = object({
    enabled = bool
    id      = optional(string)
  })
  description = "Spacelift AWS integration configuration"

  default = {
    enabled = false
  }

  validation {
    condition     = var.aws_integration.enabled == false || (var.aws_integration.enabled && var.aws_integration.id != null)
    error_message = "The integration id must be included if aws_entegration is enabled."
  }
}

variable "bitbucket_cloud_namespace" {
  type        = string
  description = "The namespace of the Bitbucket Cloud account to use for the stack. Required if cloud_integration is BITBUCKET."
  default     = null
}

variable "vcs_integration" {
  type        = string
  description = "The cloud integration to use for the stack. BITBUCKET or GITHUB."
  default     = "GITHUB"

  validation {
    condition     = var.vcs_integration == "BITBUCKET" || var.vcs_integration == "GITHUB"
    error_message = "The cloud integration must be either BITBUCKET or GITHUB."
  }
}

variable "cloudformation" {
  type = object({
    stack_name          = string
    entry_template_file = string
    region              = string
    template_bucket     = string
  })
  description = "Cloudformation integration configuration"
  default     = null
}

variable "dependencies" {
  type = map(object({
    dependent_stack_id = string
    input_name         = optional(string)
    output_name        = optional(string)
    trigger_always     = optional(bool)
  }))
  description = "Stack dependencies to add to the stack."
  default     = {}
}

variable "description" {
  type        = string
  description = "REQUIRED A description to describe your Spacelift stack."
}

variable "environment_variables" {
  type = map(object({
    value     = string
    sensitive = optional(bool, false)
  }))
  description = "Environment variables to add to the context."
  default     = {}
}

variable "labels" {
  type        = list(string)
  description = "Labels to apply to the stack being created."
  default     = []
}

variable "manage_state" {
  type        = bool
  description = "Should spacelift manage state files"
  default     = true
}

variable "name" {
  type        = string
  description = "REQUIRED The name of the Spacelift stack to create."
}

variable "policies" {
  type = map(object({
    file_path = string
    type      = string
  }))
  description = "Policies to add to the stack."
  default     = {}
}

variable "project_root" {
  type        = string
  description = "The path to your project root in your repository to use as the root of the stack. Defaults to root of the repository."
  default     = null
}

variable "repository_branch" {
  type        = string
  description = "The name of the branch to use for the specified Git repository."
  default     = "main"
}

variable "repository_name" {
  type        = string
  description = "REQUIRED The name of the Git repository for the stack to use."
}

variable "runner_image" {
  type        = string
  description = "The runner image to use for the stack. Defaults to the latest version."
  default     = null
}

variable "space_id" {
  type        = string
  description = "REQUIRED The ID of the space this stack will be in."
}

variable "terragrunt_config" {
  type = object({
    terraform_version    = string
    terragrunt_version   = string
    use_run_all          = optional(bool)
    use_smart_sanitation = optional(bool)
    tool                 = string
  })
  description = "config for terragrunt in spacelift"
  default = {
    terraform_version  = null
    terragrunt_version = null
    tool               = null
  }
}

variable "tf_version" {
  type        = string
  description = "The version of OpenTofu/Terraform for your stack to use. Defaults to latest."
  default     = "1.7.1"
}

variable "tf_workspace" {
  type        = string
  description = "The workspace to use for the stack."
  default     = null
}

variable "worker_pool_id" {
  type        = string
  description = "The ID of the worker pool to use for Spacelift stack runs. Defaults to public worker pool."
  default     = null
}

variable "workflow_tool" {
  type        = string
  description = "The workflow tool to use"
  default     = "OPEN_TOFU"

  validation {
    condition     = var.workflow_tool == "TERRAFORM_FOSS" || var.workflow_tool == "OPEN_TOFU" || var.workflow_tool == "CLOUDFORMATION" || var.workflow_tool == "TERRAGRUNT"
    error_message = "The workflow tool must be TERRAFORM_FOSS, OPEN_TOFU, CLOUDFORMATION, or TERRAGRUNT."
  }
}
