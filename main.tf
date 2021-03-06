provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

terraform {
  cloud {
    organization = "arun_learning"

    workspaces {
      name = "terraform-compute"
    }
  }
}

module "test-vpc-module" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 4.0"
  project_id   = var.project_id
  network_name = "custom-network1"
  mtu          = 1460

  subnets = [
    {
      subnet_name   = "subnet-us-central-192"
      subnet_ip     = "192.168.1.0/24"
      subnet_region = var.region
    }
  ]
}

resource "google_compute_instance" "vm_instance" {
  project      = var.project_id
  zone         = var.zone
  name         = "terraform-instance"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network    = module.test-vpc-module.network_name
    subnetwork = "subnet-us-central-192"
  }
}