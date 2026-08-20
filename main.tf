module "vpc" {
  source = "./modules/vpc"

  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}

module "ec2" {
  source = "./modules/ec2"

  vpc_id                  = module.vpc.vpc_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_app_subnet_ids  = module.vpc.private_app_subnet_ids

  instance_type           = var.instance_type
  ami_id                  = var.ami_id
  key_name                = var.key_name

  web_security_group_id   = module.vpc.web_security_group_id
  app_security_group_id   = module.vpc.app_security_group_id
}

module "rds" {
  source = "./modules/rds"

  vpc_id                 = module.vpc.vpc_id
  private_db_subnet_ids  = module.vpc.private_db_subnet_ids

  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
  instance_class         = var.db_instance_class

  db_security_group_id   = module.vpc.db_security_group_id
}
