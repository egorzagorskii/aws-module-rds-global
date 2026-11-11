provider "aws" {
  region = local.primary_region
}

locals {
  name = "ex-global-aurora"

  primary_region   = "eu-west-1"
  secondary_region = "us-east-1"

  tags = {
    Example = local.name
  }
}

################################################################################
# Global Cluster
################################################################################

module "global_cluster" {
  source = "../../"

  global_cluster_identifier = local.name
  engine                    = "aurora-postgresql"
  engine_version            = "17.5"
  database_name             = "example_db"

  tags = local.tags
}

################################################################################
# Regional Clusters
################################################################################

module "aurora_primary" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 10.4"

  name                      = local.name
  database_name             = module.global_cluster.global_cluster_database_name
  engine                    = module.global_cluster.global_cluster_engine
  engine_version            = module.global_cluster.global_cluster_engine_version
  global_cluster_identifier = module.global_cluster.global_cluster_id
  master_username           = "root"
  cluster_instance_class    = "db.r8g.large"
  instances                 = { for i in range(2) : i => {} }
  kms_key_id                = var.primary_kms_key_arn

  vpc_id               = var.primary_vpc_id
  db_subnet_group_name = var.primary_db_subnet_group_name

  # Global clusters do not support managed master user password
  master_password_wo         = random_password.master.result
  master_password_wo_version = 1

  skip_final_snapshot = true

  tags = local.tags
}

module "aurora_secondary" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 10.4"

  region = local.secondary_region

  is_primary_cluster = false

  name                      = local.name
  engine                    = module.global_cluster.global_cluster_engine
  engine_version            = module.global_cluster.global_cluster_engine_version
  global_cluster_identifier = module.global_cluster.global_cluster_id
  source_region             = local.primary_region
  cluster_instance_class    = "db.r8g.large"
  instances                 = { for i in range(2) : i => {} }
  kms_key_id                = var.secondary_kms_key_arn

  vpc_id               = var.secondary_vpc_id
  db_subnet_group_name = var.secondary_db_subnet_group_name

  skip_final_snapshot = true

  depends_on = [
    module.aurora_primary
  ]

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

resource "random_password" "master" {
  length  = 20
  special = false
}
