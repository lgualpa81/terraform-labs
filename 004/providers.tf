terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      #version = "~> 3.0"      
      version = "3.5.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
