# Global cluster built around an existing primary cluster.
# Place next to the primary component, e.g. <region-a>/<group>/<service>/db/rds-global
#
# Apply order: rds (primary) -> rds-global -> secondary rds in region B.
# The primary cluster must NOT use RDS-managed master password
# (manage_master_user_password = false + master_password_wo).

terraform {
  source = "git::git@github.com:inDriver/aws-module-rds-global.git//.?ref=v2.0.0"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "primary" {
  config_path = "../rds"

  mock_outputs = {
    cluster_arn = "arn:aws:rds:eu-west-1:000000000000:cluster:mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "application" {
  config_path = "../../application"
}

locals {
  service = basename(dirname("${get_terragrunt_dir()}/../../"))
}

inputs = {
  global_cluster_identifier    = "${local.service}-aurora-global"
  source_db_cluster_identifier = dependency.primary.outputs.cluster_arn

  # engine / engine_version / database_name / storage_encrypted are inherited
  # from the source cluster. Leave them unset here: a pinned engine_version
  # drifts as soon as anything upgrades the cluster outside this component.

  deletion_protection = true

  tags = merge(
    dependency.application.outputs.tags_all,
    { cur-prod-service = local.service }
  )
}
