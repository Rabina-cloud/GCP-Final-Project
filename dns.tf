resource "google_dns_managed_zone" "zone" {
  name     = "public-zone"
  dns_name = "${var.domain_name}."
}

resource "google_dns_record_set" "app" {
  name         = "app.${var.domain_name}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_compute_global_address.lb_ip.address]
}
