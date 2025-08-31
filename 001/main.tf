
resource "random_id" "file_suffix" {
  byte_length = 4
}

resource "local_file" "devops_journey" {
  filename = local.filename
  content = templatefile("${path.module}/templates/welcome.tpl", {
    name      = var.student_name
    day       = 21
    timestamp = local.timestamp
    tools     = var.devops_tools
  })

  file_permission = "0644"
}

resource "local_file" "terraform_config" {
  filename = "terraform-config.json"
  content = jsonencode({
    project = {
      name       = "devops-project"
      day        = 21
      topic      = "terraform-basics"
      created_at = local.timestamp
      student    = var.student_name
    }

    terraform = {
      version = "1.6+"
      providers = {
        local  = "~> 2.4"
        random = "~> 3.4"
      }
    }
    learning_objectives = [
      "Understand IaC concepts",
      "Learn Terraform basics",
      "Create first resources",
      "Manage state files"
    ]
  })

}
