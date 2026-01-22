resource "google_storage_bucket" "static" {
  name                        = "${var.project_id}-static"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "ingestion" {
  name                        = "${var.project_id}-ingestion"
  location                    = "US"
  uniform_bucket_level_access = true
}
