terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.76.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "3.76.0"
    }
  }
}

provider "google" {
  project = local.gcp_project
  region = local.region
}

provider "google-beta" {
  project = local.gcp_project
  region = local.region
}