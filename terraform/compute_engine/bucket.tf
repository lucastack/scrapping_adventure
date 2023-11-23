resource "google_storage_bucket" "gcs" {
  project       = var.gcp_project
  name          = var.bucket_name
  location      = "US"
  force_destroy = true
}

