locals {
  common_tags = {
    environment = var.environment
    managedBy   = var.team
    createdBy   = "terraform"
  }

  application_data = {
    for domain_name, domain_data in var.applications: 
    domain_name => {
        team          = domain_name
        db_identifier = domain_name
        db_config     = domain_data.postgress
    } if can(domain_data.postgress)
}
}

resource "aws_db_subnet_group" "this" {
  name       = "db-subnet-group-${local.common_tags.environment}"
  subnet_ids = var.db_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "db-subnet-group-${local.common_tags.environment}"
    }
  )
}

resource "aws_db_parameter_group" "this" {
  for_each =  local.application_data

  name_prefix = each.key
  family      =  each.value.db_config.db_family

  parameter {
    name  = "log_connections"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "rds-${each.key}-${local.common_tags.environment}"
    }
  )
}

resource "aws_db_instance" "this" {
  for_each =  local.application_data

  db_subnet_group_name = aws_db_subnet_group.this.name
  allocated_storage    = 10

  identifier     = each.key
  engine         = each.value.db_config.engine
  engine_version = each.value.db_config.engine_version
  instance_class = each.value.db_config.instance_class
  username       = each.value.db_config.username
  password       = each.value.db_config.password
  parameter_group_name = aws_db_parameter_group.this[each.key].name
  skip_final_snapshot = each.value.db_config.skip_final_snapshot

  tags = merge(
    local.common_tags,
    {
      Name = "rds-${each.key}-${local.common_tags.environment}"
    }
  )
}