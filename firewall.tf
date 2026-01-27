resource "google_compute_firewall" "allow_health_checks" {
  name      = "allow-health-checks"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags = ["web-mig"]
}

resource "google_compute_firewall" "allow_http_web" {
  name      = "allow-http-web"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 1100

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-mig"]
}

# Allow internal traffic within the VPC
resource "google_compute_firewall" "allow_internal" {
  name      = "allow-internal"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 1200

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.10.0.0/16"]
}