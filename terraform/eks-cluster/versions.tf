terraform {
  required_version = ">= 0.14.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.73.0" # specify the version you want to use
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.4.1" # specify the version you want to use
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0" # specify the version you want to use
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0" # specify the version you want to use
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0" # specify the version you want to use
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0" # specify the version you want to use
    }
  }
}