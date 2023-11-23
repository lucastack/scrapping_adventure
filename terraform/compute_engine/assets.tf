resource "google_storage_bucket_object" "assets" {
  name       = format("%s-%s.zip", "assets", data.archive_file.source_zip.output_md5)
  source     = format("%ssource.zip", "../src/")
  bucket     = var.bucket_name
  depends_on = [google_storage_bucket.gcs]
}

data "archive_file" "source_zip" {
  type        = "zip"
  source_dir  = "../src/"
  output_path = format("%ssource.zip", "../src/")
}
