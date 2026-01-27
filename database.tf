resource "google_compute_global_address" "psa_range" {
  name          = "psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "psa" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_range.name]
}

resource "google_sql_database_instance" "main" {
  name             = "app-sql-instance"
  region           = var.region
  database_version = "MYSQL_8_0"

  depends_on = [google_service_networking_connection.psa]

  deletion_protection = false

  settings {
    tier              = "db-custom-2-7680"
    availability_type = "REGIONAL" # optional HA

    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.self_link
    }
  }
}

resource "google_sql_database" "db" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  password = var.db_password
}