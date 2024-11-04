locals {
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "bastion" {
  source = "../../modules/bastion"

  project = var.project_name
  env     = var.environment
  vpc_id  = module.network.vpc_id

  public_subnet_id = module.network.public_subnet_ids[0]
  db_security_group_id = module.database.db_security_group_id
}

module "network" {
  source = "../../modules/network"

  project         = var.project_name
  env            = var.environment
  vpc_cidr       = local.vpc_cidr
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
}

module "database" {
  source = "../../modules/database"

  project            = var.project_name
  env               = var.environment
  vpc_id            = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

module "container" {
  source = "../../modules/container"

  project = var.project_name
  env     = var.environment

  db_name = var.db_name
  db_endpoint = module.database.db_endpoint
  db_username = var.db_username
  db_password = var.db_password
  private_subnet_ids = module.network.private_subnet_ids
  db_security_group_id = module.database.db_security_group_id
  public_subnet_ids = module.network.public_subnet_ids
  vpc_id = module.network.vpc_id
}

module "amplify" {
  source = "../../modules/amplify"

  project            = var.project_name
  env               = var.environment
  repository_url    = var.repository_url
  github_access_token = var.github_access_token
  api_domain        = module.container.api_domain
}
