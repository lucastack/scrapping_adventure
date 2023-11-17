resource "google_compute_instance" "instance-1" {
  boot_disk {
    auto_delete = true
    device_name = var.vm_name

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20231115"
      size  = 30
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-medium"
  name         = "instance-1"

  network_interface {
    network = "default"
  }
  
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["http-server", "https-server", "lb-health-check"]
  zone = var.zone
}

