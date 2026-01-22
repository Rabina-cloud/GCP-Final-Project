resource "google_sql_database_instance" "db" {
  name             = "app-db"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }
}
