resource "google_storage_bucket" "gcp_bucket" {
  name                        = "${var.project_id}-gcp_bucket-bucket-123"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_v1" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}