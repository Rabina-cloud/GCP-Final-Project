############################################
# VPC Connector for Cloud Run (Private IP)
############################################
resource "google_vpc_access_connector" "run_connector" {
  name          = "run-vpc-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"

  min_instances = 2
  max_instances = 3
  machine_type  = "e2-micro"
}

############################################
# Cloud Run Service Account
############################################
resource "google_service_account" "cloudrun_sa" {
  account_id   = "cloudrun-sa"
  display_name = "Cloud Run Service Account"
}

############################################
# Secret Manager Access for Cloud Run
############################################
resource "google_project_iam_member" "cloudrun_secret_access" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

############################################
# Cloud Run v2 Service
############################################
resource "google_cloud_run_v2_service" "app" {
  name     = "app-service"
  location = var.region

  depends_on = [
    google_vpc_access_connector.run_connector,
    google_project_iam_member.cloudrun_secret_access
  ]

  template {
    service_account = google_service_account.cloudrun_sa.email

    vpc_access {
      connector = google_vpc_access_connector.run_connector.id
      egress    = "ALL_TRAFFIC"
    }

    containers {
      image = var.cloud_run_image

      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.main.private_ip_address
      }

      env {
        name  = "DB_NAME"
        value = var.db_name
      }

      env {
        name  = "DB_USER"
        value = var.db_user
      }

      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  # Allow public access (lock later with IAM if needed)
  ingress = "INGRESS_TRAFFIC_ALL"
}

############################################
# Output Cloud Run URL
############################################
output "cloud_run_url" {
  value = google_cloud_run_v2_service.app.uri
}