# Terragrunt usage

| Directory | What it is |
|-----------|------------|
| [promote](promote) | Global cluster built around an existing primary cluster (`source_db_cluster_identifier`) |
| [empty](empty) | Empty global cluster; primary and secondary clusters are attached afterwards |
| [secondary](secondary) | Secondary cluster in another region (`rds-aurora` module, `is_primary_cluster = false`) |

## Promote an existing cluster

1. Primary cluster (`rds/`): switch off the RDS-managed password, it is not supported for global clusters:

   ```hcl
   manage_master_user_password = false
   master_password_wo          = dependency.secret.outputs.password
   master_password_wo_version  = 1
   # remove manage_master_user_password_rotation / master_user_password_rotation_*
   ```

2. `rds-global/` from [promote](promote): `terragrunt apply`.
3. Primary cluster: add `global_cluster_identifier = "<service>-aurora-global"` (a string, not a
   dependency, to avoid a cycle). The `rds-aurora` module ignores changes to this attribute, so
   `terragrunt plan` must show no changes.
4. Secondary cluster from [secondary](secondary): `terragrunt apply`. A cluster that already exists
   cannot join a global cluster; it has to be created as a secondary.

## Checks

```bash
aws rds describe-global-clusters --global-cluster-identifier <id> \
  --query 'GlobalClusters[0].GlobalClusterMembers[].[DBClusterArn,IsWriter]' --output table

aws rds describe-db-clusters --region <region-b> --db-cluster-identifier <secondary> \
  --query 'DBClusters[0].[Status,GlobalClusterIdentifier,EngineVersion]'
```

## Destroy order

secondary -> primary (or keep it: `force_destroy` only detaches members) -> rds-global.
`deletion_protection` must be set to `false` and applied before destroying the global cluster.
