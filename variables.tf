variable "create" {
  description = "Whether the global cluster should be created"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Global Cluster
################################################################################

variable "global_cluster_identifier" {
  description = "The global cluster identifier"
  type        = string
}

variable "source_db_cluster_identifier" {
  description = "ARN of an existing regional DB cluster to promote into the primary cluster of the new global cluster. Engine, engine version, database name and encryption are inherited from it. Changes after creation are ignored"
  type        = string
  default     = null
}

variable "engine" {
  description = "Name of the database engine to be used for the global cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql`. Required unless `source_db_cluster_identifier` is set"
  type        = string
  default     = null

  validation {
    condition     = var.engine == null || contains(["aurora", "aurora-mysql", "aurora-postgresql"], coalesce(var.engine, "-"))
    error_message = "engine must be one of: aurora, aurora-mysql, aurora-postgresql."
  }
}

variable "engine_version" {
  description = "Engine version of the global cluster. Upgrading the engine version triggers an in-place upgrade of all member clusters. Leave `null` with `source_db_cluster_identifier` to inherit it"
  type        = string
  default     = null
}

variable "engine_lifecycle_support" {
  description = "The life cycle type for the global cluster (Aurora PostgreSQL only). Valid values: `open-source-rds-extended-support`, `open-source-rds-extended-support-disabled`"
  type        = string
  default     = null
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation. Ignored with `source_db_cluster_identifier`"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the global cluster is encrypted. Ignored with `source_db_cluster_identifier` (inherited from the source cluster)"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "If the global cluster should have deletion protection enabled. The global cluster can't be deleted when this value is set to `true`"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Enable to remove DB cluster members from the global cluster on destroy (member clusters are detached, not deleted). Defaults to `true` with `source_db_cluster_identifier`, which the provider requires"
  type        = bool
  default     = null
}

variable "timeouts" {
  description = "Create, update, and delete timeout configurations for the global cluster"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
