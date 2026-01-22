variable "project_id" {}
variable "region" {}

variable "vpc_name" {
  default = "prod-vpc"
}

variable "subnet_cidrs" {
  type = map(string)
}

variable "domain_name" {}

variable "db_tier" {
  default = "db-custom-2-7680"
}
