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

variable "db_subnet_group_ids" {
  type    = list(string)
}

variable "applications" {
  type = map(object({
    postgress = object({
      db_name = {
        engine               = string
        engine_version       = string
        instance_class       = string
        username             = string
        password             = string
        parameter_group_name = string
        skip_final_snapshot  = bool
      }
    })
  }))
  default = {
    "devops" = {
      postgress = ["devops-test-db"]
    }
  }
}

variable "rds_config" {
  type = map(object({
    postgress = list(string)
  }))
  default = {
    "devops" = {
      postgress = ["devops-test-db"]
    }
  }
}