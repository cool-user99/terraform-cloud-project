locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "network" {
  source = "../../modules/network"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  azs                = local.azs
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
}

module "security" {
  source = "../../modules/security"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  create_iam_role       = var.create_iam_role
  instance_profile_name = var.instance_profile_name
}

module "load_balancer" {
  source = "../../modules/load-balancer"

  name_prefix       = local.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  certificate_arn   = var.certificate_arn
}

module "compute" {
  source = "../../modules/compute"

  name_prefix           = local.name_prefix
  tags                  = local.common_tags
  private_subnet_ids    = module.network.private_app_subnet_ids
  app_sg_id             = module.security.app_sg_id
  instance_profile_name = module.security.instance_profile_name
  target_group_arn      = module.load_balancer.target_group_arn
  instance_type         = var.instance_type
  min_size              = var.min_size
  max_size              = var.max_size
}

module "database" {
  source = "../../modules/database"

  name_prefix           = local.name_prefix
  private_db_subnet_ids = module.network.private_db_subnet_ids
  db_sg_id              = module.security.db_sg_id
  db_instance_class     = var.db_instance_class
  multi_az              = var.db_multi_az
  skip_final_snapshot   = var.db_skip_final_snapshot
  use_secrets_manager   = var.db_use_secrets_manager
}

module "storage" {
  source = "../../modules/storage"

  name_prefix   = local.name_prefix
  create_bucket = var.storage_create_bucket
  force_destroy = var.storage_force_destroy
}
