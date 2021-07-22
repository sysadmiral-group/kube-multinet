resource google_compute_instance master0 {
  name         = "kube-mn-master0"
  machine_type = "n2-standard-4"
  project = local.gcp_project
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  can_ip_forward = true
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }    
  }
  network_interface {
    subnetwork = google_compute_subnetwork.net0_subnet0.self_link
  }
  network_interface {
    subnetwork = google_compute_subnetwork.net1_subnet0.self_link
  }  

 
  allow_stopping_for_update = true
#   metadata_startup_script = <<-EOF
#   EOF

}

resource google_compute_instance n0_0 {
  name         = "kube-mn-n0-0"
  machine_type = "n2-standard-2"
  project = local.gcp_project
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  can_ip_forward = true
  network_interface {
    subnetwork = google_compute_subnetwork.net0_subnet0.self_link
    access_config {
      // Ephemeral IP
    }      
  }
 
  allow_stopping_for_update = true
#   metadata_startup_script = <<-EOF
#   EOF

}

resource google_compute_instance n1_0 {
  name         = "kube-mn-n1-0"
  machine_type = "n2-standard-2"
  project = local.gcp_project
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  can_ip_forward = true
  network_interface {
    subnetwork = google_compute_subnetwork.net1_subnet0.self_link
    access_config {
      // Ephemeral IP
    }      
  }
 
  allow_stopping_for_update = true
#   metadata_startup_script = <<-EOF
#   EOF

}