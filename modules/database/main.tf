resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnets"
  }
}

# Utilise uniquement si Secrets Manager n'est pas disponible
resource "random_password" "db" {
  count = var.use_secrets_manager ? 0 : 1

  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+"
}

resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-db"

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = var.use_secrets_manager ? true : null
  password                    = var.use_secrets_manager ? null : random_password.db[0].result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period    = var.backup_retention_period
  auto_minor_version_upgrade = true
  apply_immediately          = true

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-db-final"
  deletion_protection       = var.deletion_protection

  tags = {
    Name = "${var.name_prefix}-db"
  }
}
