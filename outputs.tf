################################################################################
# Global Cluster
################################################################################

output "global_cluster_id" {
  description = "The RDS global cluster identifier. Pass it to the `global_cluster_identifier` input of the `terraform-aws-modules/rds-aurora/aws` module"
  value       = try(aws_rds_global_cluster.this[0].id, null)
}

output "global_cluster_arn" {
  description = "Amazon Resource Name (ARN) of the global cluster"
  value       = try(aws_rds_global_cluster.this[0].arn, null)
}

output "global_cluster_resource_id" {
  description = "AWS Region-unique, immutable identifier for the global cluster"
  value       = try(aws_rds_global_cluster.this[0].global_cluster_resource_id, null)
}

output "global_cluster_endpoint" {
  description = "Writer endpoint of the global cluster. Always points to the writer instance of the current primary cluster"
  value       = try(aws_rds_global_cluster.this[0].endpoint, null)
}

output "global_cluster_members" {
  description = "Set of objects containing the ARN (`db_cluster_arn`) and writer flag (`is_writer`) of the global cluster members"
  value       = try(aws_rds_global_cluster.this[0].global_cluster_members, null)
}

output "global_cluster_engine" {
  description = "The database engine of the global cluster"
  value       = try(aws_rds_global_cluster.this[0].engine, null)
}

output "global_cluster_engine_version" {
  description = "The configured engine version of the global cluster"
  value       = try(aws_rds_global_cluster.this[0].engine_version, null)
}

output "global_cluster_engine_version_actual" {
  description = "The running engine version of the global cluster"
  value       = try(aws_rds_global_cluster.this[0].engine_version_actual, null)
}

output "global_cluster_database_name" {
  description = "Name of the automatically created database"
  value       = try(aws_rds_global_cluster.this[0].database_name, null)
}
