resource "docker_network" "webapp_network" {
  name = var.network_name
}

module "database" {
  source              = "./modules/database"
  network_id          = docker_network.webapp_network.id
  pg_container_name   = "${var.project_name}-db"
  pg_image_name       = var.images["db"]
  pg_db_user          = var.pg_db_user
  pg_db_password      = var.pg_db_password
  pg_db_name          = var.pg_db_name
  pg_external_port    = var.external_ports.pg
  pg_init_script_path = abspath("${path.root}/modules/database/init.sql")
  pg_volume_name      = "pg_data"
}

module "cache" {
  source               = "./modules/cache"
  network_id           = docker_network.webapp_network.id
  redis_container_name = "${var.project_name}-cache"
  redis_image_name     = var.images["cache"]
  redis_volume_name    = "redis_data"
  redis_external_port  = var.external_ports.redis
}

module "worker" {
  source                = "./modules/worker"
  network_id            = docker_network.webapp_network.id
  depends_on            = [module.database, module.cache]
  worker_image_name     = var.images["worker"]
  worker_container_name = "${var.project_name}-worker"
  pg_host               = var.pg_host
  pg_db_user            = var.pg_db_user
  pg_db_password        = var.pg_db_password
  pg_db_name            = var.pg_db_name
  redis_host            = var.redis_host
}

module "results" {
  source                = "./modules/results"
  network_id            = docker_network.webapp_network.id
  depends_on            = [module.database, module.cache]
  result_image_name     = var.images["result"]
  result_container_name = "${var.project_name}-result"
  result_external_port  = var.external_ports.result
  pg_host               = var.pg_host
  pg_db_user            = var.pg_db_user
  pg_db_password        = var.pg_db_password
  pg_db_name            = var.pg_db_name
}

module "vote" {
  source              = "./modules/vote"
  network_id          = docker_network.webapp_network.id
  depends_on          = [module.database, module.cache]
  vote_image_name     = var.images["vote"]
  vote_container_name = "${var.project_name}-vote"
  redis_host          = var.redis_host
  pg_host             = var.pg_host
  pg_db_user          = var.pg_db_user
  pg_db_password      = var.pg_db_password
  pg_db_name          = var.pg_db_name
}

module "gateway" {
  source                   = "./modules/gateway"
  network_id               = docker_network.webapp_network.id
  depends_on               = [module.vote]
  gateway_image_name       = var.images["nginx"]
  gateway_container_name   = "${var.project_name}-gateway"
  gateway_init_script_path = abspath("${path.root}/modules/gateway/config/nginx.conf")
  gateway_external_port    = var.external_ports.nginx
}
