variable "project_name" {
  description = "Project name used in resource naming and tags"
  type        = string
  default     = "cgep-lab2.3"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "production"
}

variable "bucket_suffix" {
  description = "Optional suffix for bucket names; if empty, a random suffix is generated"
  type        = string
  default     = ""
}
