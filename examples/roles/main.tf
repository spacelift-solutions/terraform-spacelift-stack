terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = ">=1.16.1"
    }
  }
}

# Create a custom role with specific permissions
resource "spacelift_role" "custom" {
  name        = "Custom Stack Operator"
  description = "A role that can read Space resources, trigger stacks, and confirm runs"

  # Grant specific permissions to the role
  actions = ["SPACE_READ", "STACK_UPDATE", "RUN_CONFIRM"]
}

# Create a target space where the roles will be effective
resource "spacelift_space" "target" {
  name            = "role-test-target-space"
  parent_space_id = "root"
  description     = "Target space for role attachment testing"
}

data "spacelift_role" "reader" {
  slug = "space-reader"
}

# Create a stack with role attachments
module "stack_with_roles" {
  source = "../.."

  space_id          = "root"
  repository_name   = "demo"
  repository_branch = "main"
  name              = "stack-with-role-attachments"
  description       = "Test case demonstrating role attachments with custom and reader roles"
  workflow_tool     = "OPEN_TOFU"
  tf_version        = "latest"

  # Attach both a custom role and the built-in reader role
  roles = {
    CUSTOM_ROLE = {
      role_id  = spacelift_role.custom.id
      space_id = spacelift_space.target.id
    }
    READER_ROLE = {
      role_id  = data.spacelift_role.reader.id # Built-in reader role
      space_id = spacelift_space.target.id
    }
  }
}
