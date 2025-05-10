module "ami-id" {
  source = "./modules/get-ami-id"
  k8s_version = var.k8s_version
}

module "create-k8s-vpc" {
  source = "./modules/create-k8s-vpc"
}

module "create-k8s-security-group" {
  source = "./modules/create-k8s-security-group"
  vpc_id = module.vpc.vpc_id
}

module "init-cluster" {
  source = "./modules/init-cluster"
  ami = module.ami-id.id
  control_plane_count = var.control_plane_count
  worker_count = var.worker_count
}

module "create-control-plane" {
  source = "./modules/create-control-plane"
  ami = module.ami-id.id
  secrests = module.init-cluster.control-plane-secrets
}

module "create-worker" {
  source = "./modules/create-worker"
  ami = module.ami-id.id
  secrests = module.init-cluster.worker-secrets
}