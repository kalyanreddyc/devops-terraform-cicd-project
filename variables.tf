variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}
variable "git_token" {
  description = "The Git personal access token"
  type        = string
  sensitive   = true
}

variable "git_username" {
  description = "The Git username"
  type        = string
}