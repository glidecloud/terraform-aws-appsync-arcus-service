variable "org" {
  description = "Organization name used in the GraphQL API name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region to use by default"
  type        = string
}

variable "api_name" {
  description = "AppSync GraphQL API name"
  type        = string
}

variable "api_hostname" {
  description = "HTTP domain hostname for the Arcus service"
  type        = string
}

variable "authentication_type" {
  description = "Default authentication type for API requests"
  type        = string
  default     = "API_KEY"
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}

variable "cloudwatch_logs_enabled" {
  description = "Enable Cloudwatch logs for requests to AppSync"
  type        = bool
  default     = false
}

