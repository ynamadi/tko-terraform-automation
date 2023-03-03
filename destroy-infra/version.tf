terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "3.2.1"
    }
    local = {
      source = "hashicorp/local"
    }
    http-full = {
      source = "salrashid123/http-full"
      version = "1.3.1"
    }
  }
}

provider "http-full" {}