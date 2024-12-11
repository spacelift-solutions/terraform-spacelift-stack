# Spacelift Stack Module

This is a Terraform module that creates a Spacelift stack.
Not everything is implemented yet, but we are actively building this project out.
Please open a PR or an issue if you see missing functionality.

<!-- BEGIN_TF_DOCS -->
## Example

```hcl
module "ec2_worker_pool_stack" {
  source = "spacelift.io/spacelift-solutions/stacks-module/spacelift"

  name              = "worker-pool-stack"
  description       = "Stack to create a worker pool"
  repository_name   = "spacelift"
  repository_branch = "main"
  project_root      = "aws/ecs-worker-pool"
  labels            = ["worker-pool", "example"]
  manage_state      = true

  auto_deploy     = true
  administrative  = true
  allow_promotion = true
  tf_version      = "1.7.1"
  tf_workspace    = "worker-pool"
  workflow_tool   = "OPEN_TOFU"

  runner_image = "public.ecr.aws/spacelift/runner-terraform"

  vcs = {
    type       = "GITHUB"
    enterprise = false
    id         = "my-github-integration-id"
    namespace  = "my-namespace"
    url        = "my-url"

  }

  cloudformation = {
    stack_name          = "worker-pool"
    entry_template_file = "cloudformation/worker-pool.yml"
    region              = "us-west-2"
    template_bucket     = "my-template-bucket"
  }

  kubernetes_config = {
    kubectl_version = "latest"
    namespace       = "default"
  }

  terragrunt_config = {
    terragrunt_version   = "0.66.3"
    terraform_version    = "1.8.1"
    use_run_all          = true
    use_smart_sanitation = true
    tool                 = "OPEN_TOFU"
  }

  additional_project_globs = [
    "modules/spacelift/worker-pool/**/*"
  ]

  environment_variables = {
    TF_VAR_worker_pool_config = {
      sensitive = true
      value = jsonencode({
        token       = spacelift_worker_pool.this.config
        private_key = base64encode(tls_private_key.this.private_key_pem)
      })
    }
  }

  policies = {
    MY_AWESOME_PUSH_POLICY = {
      file_path = "./policies/push/awesome.rego"
      type      = "GIT_PUSH"
    }
  }

  dependencies = {
    MY_AWESOME_STACK = {
      child_stack_id = spacelift_stack.this.id

      references = {
        INPUT_1 = {
          input_name  = "INPUT_NAME_1"
          output_name = "OUTPUT_NAME_1"
        },
        INPUT_2 = {
          input_name     = "INPUT_NAME_2"
          output_name    = "OUTPUT_NAME_2"
          trigger_always = true
        },
      }
    }

    MY_OTHER_AWESOME_STACK = {
      dependent_stack_id = spacelift_stack.this.id
    }
  }

  hooks = {
    after = {
      apply = [
        "ls -lah"
      ]
    },
    before = {
      plan = [
        "echo 'Hello, World!'"
      ]
    }
  }

  worker_pool_id = spacelift_worker_pool.this.id
  space_id       = spacelift_space.aws.id
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.work.id
  }

  drift_detection = {
    enabled      = true
    schedule     = ["*/15 * * * *"]
    reconcile    = true
    ignore_state = false
    timezone     = "UTC"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_project_globs"></a> [additional\_project\_globs](#input\_additional\_project\_globs) | Additional project globs to add to the stack. | `list(string)` | `[]` | no |
| <a name="input_administrative"></a> [administrative](#input\_administrative) | Whether the stack is administrative or not. | `bool` | `false` | no |
| <a name="input_allow_promotion"></a> [allow\_promotion](#input\_allow\_promotion) | Whether to allow promotion of the stack to the next environment. | `bool` | `true` | no |
| <a name="input_ansible_playbook"></a> [ansible\_playbook](#input\_ansible\_playbook) | The path to the Ansible playbook to use for the stack. | `string` | `null` | no |
| <a name="input_auto_deploy"></a> [auto\_deploy](#input\_auto\_deploy) | Whether to auto deploy the stack. | `bool` | `false` | no |
| <a name="input_aws_integration"></a> [aws\_integration](#input\_aws\_integration) | Spacelift AWS integration configuration | <pre>object({<br/>    enabled = bool<br/>    id      = optional(string)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_cloudformation"></a> [cloudformation](#input\_cloudformation) | Cloudformation integration configuration | <pre>object({<br/>    stack_name          = string<br/>    entry_template_file = string<br/>    region              = string<br/>    template_bucket     = string<br/>  })</pre> | `null` | no |
| <a name="input_dependencies"></a> [dependencies](#input\_dependencies) | Stack dependencies to add to the stack. | <pre>map(object({<br/>    parent_stack_id = optional(string)<br/>    child_stack_id  = optional(string)<br/>    references = optional(map(object({<br/>      input_name     = string<br/>      output_name    = string<br/>      trigger_always = optional(bool)<br/>    })))<br/>  }))</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | REQUIRED A description to describe your Spacelift stack. | `string` | n/a | yes |
| <a name="input_drift_detection"></a> [drift\_detection](#input\_drift\_detection) | Drift detection configuration for stack | <pre>object({<br/>    enabled      = bool<br/>    schedule     = optional(list(string))<br/>    ignore_state = optional(bool)<br/>    timezone     = optional(string)<br/>    reconcile    = optional(bool)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables to add to the context. | <pre>map(object({<br/>    value     = string<br/>    sensitive = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_hooks"></a> [hooks](#input\_hooks) | Hooks to add to the stack. | <pre>object({<br/>    before = optional(object({<br/>      init    = optional(list(string))<br/>      plan    = optional(list(string))<br/>      apply   = optional(list(string))<br/>      destroy = optional(list(string))<br/>      perform = optional(list(string))<br/>    }))<br/>    after = optional(object({<br/>      init    = optional(list(string))<br/>      plan    = optional(list(string))<br/>      apply   = optional(list(string))<br/>      destroy = optional(list(string))<br/>      perform = optional(list(string))<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_kubernetes_config"></a> [kubernetes\_config](#input\_kubernetes\_config) | Kubernetes integration configuration | <pre>object({<br/>    kubectl_version = string<br/>    namespace       = optional(string)<br/>  })</pre> | <pre>{<br/>  "kubectl_version": "latest",<br/>  "namespace": null<br/>}</pre> | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the stack being created. | `list(string)` | `[]` | no |
| <a name="input_manage_state"></a> [manage\_state](#input\_manage\_state) | Should spacelift manage state files | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | REQUIRED The name of the Spacelift stack to create. | `string` | n/a | yes |
| <a name="input_policies"></a> [policies](#input\_policies) | Policies to add to the stack. | <pre>map(object({<br/>    file_path = string<br/>    type      = string<br/>  }))</pre> | `{}` | no |
| <a name="input_project_root"></a> [project\_root](#input\_project\_root) | The path to your project root in your repository to use as the root of the stack. Defaults to root of the repository. | `string` | `null` | no |
| <a name="input_repository_branch"></a> [repository\_branch](#input\_repository\_branch) | The name of the branch to use for the specified Git repository. | `string` | `"main"` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | REQUIRED The name of the Git repository for the stack to use. | `string` | n/a | yes |
| <a name="input_runner_image"></a> [runner\_image](#input\_runner\_image) | The runner image to use for the stack. Defaults to the latest version. | `string` | `null` | no |
| <a name="input_space_id"></a> [space\_id](#input\_space\_id) | REQUIRED The ID of the space this stack will be in. | `string` | n/a | yes |
| <a name="input_terragrunt_config"></a> [terragrunt\_config](#input\_terragrunt\_config) | config for terragrunt in spacelift | <pre>object({<br/>    terraform_version    = string<br/>    terragrunt_version   = string<br/>    use_run_all          = optional(bool)<br/>    use_smart_sanitation = optional(bool)<br/>    tool                 = string<br/>  })</pre> | <pre>{<br/>  "terraform_version": null,<br/>  "terragrunt_version": null,<br/>  "tool": null<br/>}</pre> | no |
| <a name="input_tf_version"></a> [tf\_version](#input\_tf\_version) | The version of OpenTofu/Terraform for your stack to use. Defaults to latest. | `string` | `"latest"` | no |
| <a name="input_tf_workspace"></a> [tf\_workspace](#input\_tf\_workspace) | The workspace to use for the stack. | `string` | `null` | no |
| <a name="input_vcs"></a> [vcs](#input\_vcs) | VCS integration configuration | <pre>object({<br/>    type       = string<br/>    enterprise = optional(bool, false)<br/>    namespace  = optional(string)<br/>    id         = optional(string)<br/>    url        = optional(string)<br/>  })</pre> | <pre>{<br/>  "type": "GITHUB"<br/>}</pre> | no |
| <a name="input_worker_pool_id"></a> [worker\_pool\_id](#input\_worker\_pool\_id) | The ID of the worker pool to use for Spacelift stack runs. Defaults to public worker pool. | `string` | `null` | no |
| <a name="input_workflow_tool"></a> [workflow\_tool](#input\_workflow\_tool) | The workflow tool to use | `string` | `"OPEN_TOFU"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the stack |  
<!-- END_TF_DOCS -->

## Using Stack Dependencies

The following example will use `stack_1`'s output `my_awesome_output` as an input to `stack_2`'s input `my_awesome_variable`. Setting `child_stack_id` will configure the right side of the dependency view in the UI.
You can also optionally set `trigger_always` in the object to always trigger the dependent stack even if the output does not change.
```hcl
module "stack_1" {

  dependencies = {
    STACK_2 = {
      child_stack_id = module.stack_2.id
      
      references = {
        MY_AWESOME_REFERENCE = {
          output_name = "my_awesome_output"
          input_name = "TF_VAR_my_awesome_variable"
        }
      }
    }
  }
  
}

module "stack_2" {}
```

Likewise, you can also setup dependencies that a child needs from a parent stack. Setting `parent_stack_id` will configure the left side of the dependency view in the UI.
The following example and the previous example are equivalent.
```hcl
module "stack_1" {}

module "stack_2" {
  
  dependencies = {
    STACK_1 = {
      parent_stack_id = module.stack_1.id

      references = {
        MY_AWESOME_REFERENCE = {
          output_name = "my_awesome_output"
          input_name = "TF_VAR_my_awesome_variable"
        }
      }
    }
  }
  
}
```

The following example will trigger `stack_2` whenever `stack_1` is completed but will not pass any inputs and outputs.
```hcl
module "stack_1" {

  dependencies = {
    STACK_2 = {
      child_stack_id = module.stack_2.id
    }
  }
  
}

module "stack_2" {}
```