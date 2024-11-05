output "a" {
  value = spacelift_stack.this.id
}

output "id" {
  value       = spacelift_stack.this.id
  description = "The ID of the stack"
}
