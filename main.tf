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

resource "aws_security_group" "allow_db_subnet_traffic" {
  name = "allow_db_subnet_traffic"
  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "allow-dbSubnet-traffic-${local.common_tags.environment}"
    }
  )
}

resource "aws_security_group_rule" "allow_db_subnet_traffic" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.db_subnets_ipv4_cidr
  # ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.allow_db_subnet_traffic.id
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
  # parameter {
  #   name  = "rds.force_ssl"
  #   value = "0"
  # }

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
  vpc_security_group_ids = [aws_security_group.allow_db_subnet_traffic.id]

  tags = merge(
    local.common_tags,
    {
      Name = "rds-${each.key}-${local.common_tags.environment}"
    }
  )
}