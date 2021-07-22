resource google_compute_network net0 {
  name = local.net0_name
  project = local.gcp_project
  auto_create_subnetworks = false
}

resource google_compute_network net1 {
  name = local.net1_name
  project = local.gcp_project
  auto_create_subnetworks = false
}

resource google_compute_subnetwork net0_subnet0 {
  name          = local.net0_subnet_name
  ip_cidr_range = local.net0_subnet_cidr
  project       = local.gcp_project
  region        = local.region
  network       = google_compute_network.net0.id
}

resource google_compute_subnetwork net1_subnet0 {
  name          = local.net1_subnet_name
  ip_cidr_range = local.net1_subnet_cidr
  project       = local.gcp_project
  region        = local.region
  network       = google_compute_network.net1.id
}

module "peering" {
  source = "terraform-google-modules/network/google//modules/network-peering"

  local_network = google_compute_network.net0.self_link
  peer_network  = google_compute_network.net1.self_link
}

resource "google_compute_firewall" "net0_allow_external" {
  name    = "net0-allow-external"
  network = local.net0_name  
  project = local.gcp_project  
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "net1_allow_external" {
  name    = "net1-allow-external"
  network = local.net1_name  
  project = local.gcp_project 
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "net0_allow_internal" {
  name    = "net0-allow-internal"
  network = local.net0_name  
  project = local.gcp_project  
  allow {
    protocol = "all"
  }

  source_ranges = [local.net0_subnet_cidr, local.net1_subnet_cidr, "10.128.0.0/16"]
}

resource "google_compute_firewall" "net1_allow_internal" {
  name    = "net1-allow-internal"
  network = local.net1_name  
  project = local.gcp_project  
  allow {
    protocol = "all"
  }

  source_ranges = [local.net0_subnet_cidr, local.net1_subnet_cidr, "10.128.0.0/16"]
}