resource "google_compute_instance" "instance-1" {
  boot_disk {
    auto_delete = true
    device_name = var.vm_name

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20231101"
      size  = 30
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  metadata_startup_script = templatefile("startup_script.tftpl", { assets_file = google_storage_bucket_object.assets.name, bucket_name = var.bucket_name })

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-medium"
  name         = "instance-1"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    subnetwork = "projects/${var.gcp_project}/regions/${var.region}/subnetworks/default"
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

  service_account {
    email  = var.service_account
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  resource_policies = [google_compute_resource_policy.hourly.self_link]
}

resource "google_compute_resource_policy" "hourly" {
  name        = "gce-policy"
  region      = var.region
  description = "Start and stop instances"
  instance_schedule_policy {
    vm_start_schedule {
      schedule = "0 12 * * *"
    }
    vm_stop_schedule {
      schedule = "10 12 * * *"
    }
    time_zone = "Chile/Continental"
  }
}
