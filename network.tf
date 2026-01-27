resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "web" {
  name          = "subnet-web"
  ip_cidr_range = var.web_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "app" {
  name          = "subnet-app"
  ip_cidr_range = var.app_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  # Needed for Cloud Run VPC Connector egress routing
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db" {
  name                     = "subnet-db"
  ip_cidr_range            = var.db_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

# Cloud Router + NAT so private instances can reach internet for updates
resource "google_compute_router" "router" {
  name    = "nat-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "cloud-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}