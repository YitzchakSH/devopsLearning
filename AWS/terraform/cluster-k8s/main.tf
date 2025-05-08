module "ami-id" {
  source = "./modules/get-ami-id"
  k8s_version = var.k8s_version
}

module "init-cluster" {
  source = "./modules/init-cluster"
  ami = module.ami-id.id
  control_plane_count = var.control_plane_count
  worker_count = var.worker_count
}

module "create-control-plane" {
  source = "./modules/create-control-plane"
  ami = module.init-cluster.control-plane-secrets
}

module "create-worker" {
  source = "./modules/create-worker"
  ami = module.init-cluster.worker-secrets
}