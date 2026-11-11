output "global_cluster_id" {
  description = "The RDS global cluster identifier"
  value       = module.global_cluster.global_cluster_id
}

output "global_cluster_endpoint" {
  description = "Writer endpoint of the global cluster"
  value       = module.global_cluster.global_cluster_endpoint
}

output "primary_cluster_endpoint" {
  description = "Writer endpoint of the primary regional cluster"
  value       = module.aurora_primary.cluster_endpoint
}

output "secondary_cluster_reader_endpoint" {
  description = "Reader endpoint of the secondary regional cluster"
  value       = module.aurora_secondary.cluster_reader_endpoint
}
