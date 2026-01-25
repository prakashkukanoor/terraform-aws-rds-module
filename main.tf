locals {
  common_tags = {
    environment = var.environment
    managedBy   = var.team
    createdBy   = "terraform"
  }

  application_data = flatten([
    for domain_name, domain_data in var.applications : [
      { team    = domain_name
        db_name = domain_name
      db_config = domain_data.postgress }
    ]
  ])
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

resource "aws_db_instance" "this" {
  for_each = { for idx, db_obj in local.application_data : "${db_obj.db_name}${idx}" => db_obj }

  db_subnet_group_name = aws_db_subnet_group.this.name
  allocated_storage    = 10

  db_name        = each.value.db_config.db_name
  identifier     = each.value.db_config.identifier
  engine         = each.value.db_config.engine
  engine_version = each.value.db_config.engine_version
  instance_class = each.value.db_config.instance_class
  username       = each.value.db_config.username
  password       = each.value.db_config.password
  # parameter_group_name = each.value.db_config.parameter_group_name
  skip_final_snapshot = each.value.db_config.skip_final_snapshot
}