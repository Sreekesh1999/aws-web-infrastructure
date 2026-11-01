module "network" {
  source = "./modules/network"

}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}

module "iam" {
  source = "./modules/iam"
}

module "load_balancer" {
  source              = "./modules/load-balancer"
  alb_security_groups = [module.security.alb_sg_id]
  subnet_ids          = module.network.public_subnet_ids
  vpc_id              = module.network.vpc_id
}

module "compute" {
  source                = "./modules/compute"
  instance_type         = "t3.micro"
  web_security_group_id = module.security.web_sg_id
  instance_profile_name = module.iam.instance_profile_name
  private_subnet_ids    = module.network.private_subnet_ids
  target_group_arns     = [module.load_balancer.target_group_arn]
}

module "database" {
  source               = "./modules/database"
  db_subnet_group_name = "aws-web-infrastructure"
  subnet_ids           = module.network.private_subnet_ids
  db_instance_class    = "db.t3.micro"
  allocated_storage    = 20
  db_username          = var.db_username
  db_security_group_id = module.security.db_sg_id
}