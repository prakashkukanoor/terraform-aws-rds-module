locals {
  common_tags = {
    environment = var.environment
    managedBy   = var.team
    createdBy   = "terraform"
  }

  application_data = flatten([
    for domain_name, domain_data in var.applications : [
      for db_name, db_config in domain_data.postgress : {
        team      = domain_name
        db_name   = db_name
        db_config = db_config
      }
    ]
  ])
}

resource "aws_db_subnet_group" "this" {
  name       = "db-subnet-group-${locals.common_tags.environment}"
  subnet_ids = var.db_subnet_group_ids

  tags = merge(
    local.common_tags,
    {
      Name = "db-subnet-group-${locals.common_tags.environment}"
    }
  )
}

resource "aws_db_instance" "this" {
  for_each = { for idx, db_obj in locals.application_data : "${db_obj.db_name}" => db_obj }

  db_subnet_group_name = aws_db_subnet_group.this.name
  allocated_storage    = 10
  db_name              = "${each.value.team}-${each.value.db_name}"
  engine               = each.value.engine
  engine_version       = each.value.engine_version
  instance_class       = each.value.instance_class
  username             = each.value.username
  password             = each.value.password
  parameter_group_name = each.value.parameter_group_name
  skip_final_snapshot  = each.value.skip_final_snapshot
}