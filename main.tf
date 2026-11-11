locals {
  # Promote mode: the global cluster is built around an existing regional cluster.
  # Engine, version, database name and encryption are inherited from that cluster,
  # so they are not sent to AWS (sending them is either ignored or fails on an
  # unencrypted source).
  from_source = var.source_db_cluster_identifier != null
}

################################################################################
# Global Cluster
################################################################################

resource "aws_rds_global_cluster" "this" {
  count = var.create ? 1 : 0

  region = var.region

  global_cluster_identifier    = var.global_cluster_identifier
  source_db_cluster_identifier = var.source_db_cluster_identifier
  engine                       = var.engine
  engine_version               = var.engine_version
  engine_lifecycle_support     = var.engine_lifecycle_support
  database_name                = local.from_source ? null : var.database_name
  storage_encrypted            = local.from_source ? null : var.storage_encrypted
  deletion_protection          = var.deletion_protection
  # The provider requires force_destroy whenever source_db_cluster_identifier is set
  force_destroy = local.from_source ? coalesce(var.force_destroy, true) : var.force_destroy

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = local.from_source || var.engine != null
      error_message = "Set either `source_db_cluster_identifier` (promote an existing cluster) or `engine` (create an empty global cluster)."
    }

    ignore_changes = [
      # ForceNew and not readable from the API. Without this, any change of the
      # source ARN (rename, switchover, dependency output churn) would replace the
      # whole global cluster. It can also be removed from the config after creation.
      source_db_cluster_identifier,
    ]
  }
}

# v1.x managed the resource without `count`
moved {
  from = aws_rds_global_cluster.this
  to   = aws_rds_global_cluster.this[0]
}
