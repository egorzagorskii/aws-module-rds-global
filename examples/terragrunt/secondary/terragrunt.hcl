# Secondary (read-only) cluster in region B, attached to the global cluster.
# Only the inputs that differ from the regular aurora template are shown;
# vpc / core / kms / s3 role / monitoring role dependencies point to region B.

terraform {
  source = "git::git@github.com:inDriver/aws-module-rds-aurora.git//.?ref=v10.4.0-indriver.1"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "global" {
  # The global cluster component lives in the primary region
  config_path = "${get_repo_root()}/indrive-prod/<region-a>/<group>/<service>/db/rds-global"

  mock_outputs = {
    global_cluster_id             = "mock"
    global_cluster_engine         = "aurora-mysql"
    global_cluster_engine_version = "8.0.mysql_aurora.3.10.4"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "kms" {
  config_path = "../kms" # KMS key in region B
}

# ... vpc, core, role_s3, application, rds_monitoring_role as in the regular template

inputs = {
  is_primary_cluster        = false
  global_cluster_identifier = dependency.global.outputs.global_cluster_id
  source_region             = "<region-a>"
  engine                    = dependency.global.outputs.global_cluster_engine
  engine_version            = dependency.global.outputs.global_cluster_engine_version
  storage_encrypted         = true
  kms_key_id                = dependency.kms.outputs.key_arn

  # Credentials and the database come from the primary cluster:
  # no master_username, master_password_wo, database_name here.
  manage_master_user_password = false

  # Optional: let the secondary accept writes and forward them to the primary
  # enable_global_write_forwarding = true

  # ... the rest (network, SG, parameter groups, instances, monitoring, logs, tags)
  # as in the regular template. Keep parameter groups identical to the primary:
  # after a failover this cluster becomes the writer.
}
