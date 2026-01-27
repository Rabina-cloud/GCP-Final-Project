resource "google_compute_security_policy" "armor" {
  name = "web-armor-policy"

  rule {
    priority    = 1000
    action      = "allow"
    description = "Allow all (tighten later)"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  rule {
    priority    = 2147483647
    action      = "deny(403)"
    description = "Default rule (required)"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

resource "google_compute_health_check" "hc" {
  name = "web-hc"

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_backend_service" "backend" {
  name                  = "web-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30

  enable_cdn      = true
  security_policy = google_compute_security_policy.armor.id
  health_checks   = [google_compute_health_check.hc.id]

  backend {
    group = google_compute_region_instance_group_manager.web_mig.instance_group
  }
}

resource "google_compute_url_map" "urlmap" {
  name            = "web-urlmap"
  default_service = google_compute_backend_service.backend.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "web-http-proxy"
  url_map = google_compute_url_map.urlmap.id
}

resource "google_compute_global_address" "lb_ip" {
  name = "web-lb-ip"
}

resource "google_compute_global_forwarding_rule" "http_fr" {
  name                  = "web-http-fr"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.http_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.lb_ip.address
}