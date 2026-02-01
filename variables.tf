variable "region" {
  type        = string
  description = "region for bucket creation"
  default     = "us-east-1"
}


variable "environment" {
  type    = string
  default = "DEV"
}
variable "team" {
  type    = string
  default = "devops"
}
variable "vpc_id" {
  type    = string
}

variable "db_subnet_ids" {
  type    = list(string)
  default = []
}
variable "db_subnets_ipv4_cidr" {
  type    = list(string)
}
variable "applications" {
  type = map(object({
    postgress = object({
      engine         = string
      engine_version = string
      instance_class = string
      username       = string
      password       = string
      db_family      = string
      skip_final_snapshot = bool
      db_names            = list(string)
    })
  }))
}