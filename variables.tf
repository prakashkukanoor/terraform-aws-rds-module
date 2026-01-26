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

variable "db_subnet_ids" {
  type    = list(string)
  default = []
}

variable "applications" {
  type = map(object({
    postgress = object({
      engine         = string
      engine_version = string
      instance_class = string
      username       = string
      password       = string
      # parameter_group_name = string
      skip_final_snapshot = bool
      db_names            = list(string)
      # identifier          = string
    })
  }))
}