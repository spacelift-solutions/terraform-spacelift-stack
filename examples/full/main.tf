module "ec2_worker_pool_stack" {
  source = "../../"

  name            = "worker-pool-stack"
  description     = "Stack to create a worker pool"
  repository_name = "spacelift"
  project_root    = "aws/ecs-worker-pool"

  auto_deploy = true

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

  space_id = spacelift_space.aws.id
  aws_integration = {
    enabled = true
    id      = spacelift_aws_integration.work.id
  }
}