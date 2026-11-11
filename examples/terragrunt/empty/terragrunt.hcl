# Empty global cluster; the primary cluster is created afterwards with
# global_cluster_identifier = dependency.global.outputs.global_cluster_id.
#
# Apply order: rds-global -> primary rds -> secondary rds.

terraform {
  source = "git::git@github.com:inDriver/aws-module-rds-global.git//.?ref=v2.0.0"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "application" {
  config_path = "../../application"
}

locals {
  service = basename(dirname("${get_terragrunt_dir()}/../../"))
}

inputs = {
  global_cluster_identifier = "${local.service}-aurora-global"
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.10.4"
  storage_encrypted         = true
  deletion_protection       = true

  tags = merge(
    dependency.application.outputs.tags_all,
    { cur-prod-service = local.service }
  )
}
