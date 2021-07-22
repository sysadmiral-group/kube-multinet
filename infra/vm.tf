resource google_compute_address master0 {
  name         = "kube-mn-master0-public-address"
}

resource google_compute_instance master0 {
  name         = "kube-mn-master0"
  machine_type = "n2-standard-4"
  project = local.gcp_project
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-8"
    }
  }

  can_ip_forward = true
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.master0.address
    }    
  }
  network_interface {
    subnetwork = google_compute_subnetwork.net0_subnet0.self_link
    network_ip = "192.168.1.3"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.net1_subnet0.self_link
    network_ip = "10.44.1.3"
  }  

 
  allow_stopping_for_update = true
  metadata_startup_script = <<-EOF
    echo "1 rt1" | sudo tee -a /etc/iproute2/rt_tables
    ip route add 192.168.1.1 src 192.168.1.3 dev eth1 table rt1
    ip route add default via 192.168.1.1 dev eth1 table rt1
    ip rule add from 192.168.1.3/32 table rt1
    ip rule add to 192.168.1.3/32 table rt1

    echo "2 rt2" | sudo tee -a /etc/iproute2/rt_tables
    ip route add 10.44.1.1 src 10.44.1.3 dev eth2 table rt2
    ip route add default via 10.44.1.1 dev eth2 table rt2
    ip rule add from 10.44.1.3/32 table rt2
    ip rule add to 10.44.1.3/32 table rt2
  EOF
  
  lifecycle {
      ignore_changes = [
          metadata_startup_script
      ]
  }

}

resource google_compute_instance n0_0 {
  name         = "kube-mn-n0-0"
  machine_type = "n2-standard-2"
  project = local.gcp_project
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-8"
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