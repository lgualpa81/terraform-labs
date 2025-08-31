locals {
  timestamp = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  filename  = "terraform-${random_id.file_suffix.hex}.txt"
}

variable "student_name" {
  description = "Student name"
  type        = string
  default     = "devops student"

  validation {
    condition     = length(var.student_name) > 2
    error_message = "The name must have at least 3 characters"
  }
}

variable "devops_tools" {
  description = "Devops tools"
  type        = list(string)
  default     = ["docker", "docker compose", "terraform", "github actions", "kubernetes"]
}

variable "create_backup" {
  description = "Create backup file"
  type        = bool
  default     = true
}
