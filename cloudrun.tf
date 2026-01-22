resource "google_cloud_run_service" "web" {
  name     = "web"
  location = var.region

  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-egress" = "all-traffic"
      }
    }

    spec {
      service_account_name = google_service_account.web.email

      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }
}
