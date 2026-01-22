resource "google_service_account" "web" {
  account_id = "web-sa"
}

resource "google_service_account" "app" {
  account_id = "app-sa"
}

resource "google_project_iam_member" "app_sql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.app.email}"
}
