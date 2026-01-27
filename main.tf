resource "google_service_account" "web_sa" {
  account_id   = "web-mig-sa"
  display_name = "Web MIG Service Account"
}

resource "google_project_iam_member" "web_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.web_sa.email}"
}

resource "google_compute_instance_template" "web_template" {
  name_prefix  = "web-template-"
  machine_type = var.mig_machine_type
  tags         = ["web-mig"]

  disk {
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
    disk_type    = "pd-balanced"
    source_image = "projects/debian-cloud/global/images/family/debian-12"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.web.id
  }

  service_account {
    email  = google_service_account.web_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    CLOUD_RUN_URL = google_cloud_run_v2_service.app.uri
  }

  metadata_startup_script = <<-EOT
#!/bin/bash
set -e
exec > /var/log/startup-script.log 2>&1

apt-get update -y
apt-get install -y nginx curl

CLOUD_RUN_URL=$(curl -s -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/attributes/CLOUD_RUN_URL")

echo "Web Tier OK" > /var/www/html/index.html
echo "Cloud Run URL: $${CLOUD_RUN_URL}" >> /var/www/html/index.html

systemctl enable nginx
systemctl restart nginx
EOT
}

resource "google_compute_region_instance_group_manager" "web_mig" {
  name               = "web-mig"
  region             = var.region
  base_instance_name = "web"

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  target_size = 2

  named_port {
    name = "http"
    port = 80
  }

  distribution_policy_zones = [
    "${var.region}-a",
    "${var.region}-b"
  ]
}

resource "google_compute_region_autoscaler" "web_autoscaler" {
  name   = "web-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.web_mig.id

  autoscaling_policy {
    min_replicas = 2
    max_replicas = 6

    cpu_utilization {
      target = 0.6
    }
  }
}