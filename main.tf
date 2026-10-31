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
