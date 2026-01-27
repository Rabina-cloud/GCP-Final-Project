variable "project_id" {
  type    = string
  default = "	utilitarian-web-481322-k8"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "domain_name" {
  type    = string
  default = "gcp-example.com"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
  default     = "gcp-vpc"
}

variable "web_subnet_cidr" {
  type        = string
  description = "CIDR range for Web subnet"
  default     = "10.10.1.0/24"
}

variable "app_subnet_cidr" {
  type        = string
  description = "CIDR range for App subnet"
  default     = "10.10.2.0/24"
}

variable "db_subnet_cidr" {
  type        = string
  description = "CIDR range for DB subnet"
  default     = "10.10.3.0/24"
}

variable "cloud_run_image" {
  type        = string
  description = "Container image for Cloud Run"
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "db_name" {
  type        = string
  description = "Cloud SQL database name"
  default     = "appdb"
}

variable "db_user" {
  type        = string
  description = "Cloud SQL database user"
  default     = "appuser"
}

variable "db_password" {
  type        = string
  description = "Cloud SQL database password"
  sensitive   = true
  default     = "Pathfinder123!"
}

variable "mig_machine_type" {
  type        = string
  description = "Machine type for web tier MIG instances"
  default     = "e2-medium"
}
variable "mig_instance_count" {
  type        = number
  description = "Number of instances in the web tier MIG"
  default     = 2
}
variable "subnet_cidrs" {
  description = "CIDR ranges for VPC subnets"
  type        = map(string)
}