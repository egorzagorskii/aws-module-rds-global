# AWS RDS Aurora Global Cluster Terraform module

Terraform module which creates an [Aurora global database](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database.html) (`aws_rds_global_cluster`).

The module is a companion to [terraform-aws-modules/rds-aurora/aws](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora), which manages regional clusters but does not create the global cluster itself. Create the global cluster with this module, then attach regional clusters by passing its outputs to the `rds-aurora` module.

## Usage

```hcl
module "global_cluster" {
  source = "git::https://github.com/inDriver/aws-module-rds-global.git?ref=v2.0.0"

  global_cluster_identifier = "my-global-db"
  engine                    = "aurora-postgresql"
  engine_version            = "17.5"
  database_name             = "app"

  tags = {
    Environment = "prod"
  }
}

module "aurora_primary" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 10.4"

  name                      = "my-global-db"
  database_name             = module.global_cluster.global_cluster_database_name
  engine                    = module.global_cluster.global_cluster_engine
  engine_version            = module.global_cluster.global_cluster_engine_version
  global_cluster_identifier = module.global_cluster.global_cluster_id
  # ...
}

module "aurora_secondary" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 10.4"

  region             = "us-east-1"
  is_primary_cluster = false
  source_region      = "eu-west-1"

  name                      = "my-global-db"
  engine                    = module.global_cluster.global_cluster_engine
  engine_version            = module.global_cluster.global_cluster_engine_version
  global_cluster_identifier = module.global_cluster.global_cluster_id
  # ...

  depends_on = [module.aurora_primary]
}
```

### Promoting an existing cluster

To build a global cluster around an existing regional cluster, set `source_db_cluster_identifier` to the cluster ARN. Leave `engine`, `engine_version`, `database_name` and `storage_encrypted` unset: they are inherited from the source cluster and are not sent to AWS. `force_destroy` defaults to `true` in this mode, as the provider requires it.

```hcl
module "global_cluster" {
  source = "git::https://github.com/inDriver/aws-module-rds-global.git?ref=v2.0.0"

  global_cluster_identifier    = "my-global-db"
  source_db_cluster_identifier = module.aurora_primary.cluster_arn
}
```

Then set `global_cluster_identifier = "my-global-db"` (a literal, not the module output, to avoid a cycle) on the primary `rds-aurora` module. The module ignores changes to that attribute, so the plan stays empty.

Changes to `source_db_cluster_identifier` after creation are ignored: the attribute forces replacement and cannot be read back from the API, so a changed ARN (rename, switchover) would otherwise destroy the global cluster. It can be removed from the configuration once the global cluster exists.

### Terragrunt

```hcl
terraform {
  source = "git::git@github.com:inDriver/aws-module-rds-global.git//.?ref=v2.0.0"
}

dependency "primary" {
  config_path = "../rds"
}

inputs = {
  global_cluster_identifier    = "my-global-db"
  source_db_cluster_identifier = dependency.primary.outputs.cluster_arn
}
```

See [examples/terragrunt](examples/terragrunt) for promote / empty / secondary components and the apply order.

### Notes

- Global clusters do not support RDS-managed master passwords (`manage_master_user_password`). Use `master_password_wo` in the `rds-aurora` module on the primary cluster; secondary clusters take no credentials.
- An existing regional cluster cannot join a global cluster as a secondary. Secondary clusters are always created with `global_cluster_identifier` set.
- Engine upgrades are driven by `engine_version` on the global cluster. The `rds-aurora` module does not ignore `engine_version` on member clusters, so an upgrade may end with an "inconsistent final plan" error; re-run plan/apply on the member clusters after the global cluster upgrade, with their `engine_version` taken from this module's outputs.
- A pinned `engine_version` drifts if the version changes outside this module. In promote mode leave it unset.
- `deletion_protection` defaults to `true`.

## Upgrading from v1.x

- The resource moved to `aws_rds_global_cluster.this[0]`; a `moved` block handles the state, no manual `terraform state mv` is needed.
- Outputs renamed: `global_cluster_identifier` -> `global_cluster_id`, `global_writer_endpoint` -> `global_cluster_endpoint`.
- Requires AWS provider `>= 6.0`.
- `deletion_protection` now defaults to `true` (in-place change on first apply).
- With `source_db_cluster_identifier`, `storage_encrypted` and `database_name` are no longer sent; both are computed attributes, so the plan shows no change.

## Development

Run `pre-commit run --all-files` (terraform fmt/validate, TFLint, terraform-docs) before opening a PR. Each PR needs a `major`, `minor` or `patch` label, which sets the next release version.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_rds_global_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_global_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether the global cluster should be created | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name for an automatically created database on cluster creation | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the global cluster should have deletion protection enabled. The database can't be deleted when this value is set to `true` | `bool` | `null` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Name of the database engine to be used for the global cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql` | `string` | n/a | yes |
| <a name="input_engine_lifecycle_support"></a> [engine\_lifecycle\_support](#input\_engine\_lifecycle\_support) | The life cycle type for the global cluster. Valid values: `open-source-rds-extended-support`, `open-source-rds-extended-support-disabled` | `string` | `null` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Engine version of the global cluster. Upgrading the engine version triggers an in-place upgrade of all member clusters | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Enable to remove DB cluster members from the global cluster on destroy. Required with `source_db_cluster_identifier` | `bool` | `null` | no |
| <a name="input_global_cluster_identifier"></a> [global\_cluster\_identifier](#input\_global\_cluster\_identifier) | The global cluster identifier | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_source_db_cluster_identifier"></a> [source\_db\_cluster\_identifier](#input\_source\_db\_cluster\_identifier) | ARN of an existing regional DB cluster to promote into the primary cluster of the new global cluster. Changing this forces a new resource | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster is encrypted. Ignored by AWS when `source_db_cluster_identifier` is set (inherited from the source cluster) | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Create, update, and delete timeout configurations for the global cluster | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_global_cluster_arn"></a> [global\_cluster\_arn](#output\_global\_cluster\_arn) | Amazon Resource Name (ARN) of the global cluster |
| <a name="output_global_cluster_database_name"></a> [global\_cluster\_database\_name](#output\_global\_cluster\_database\_name) | Name of the automatically created database |
| <a name="output_global_cluster_endpoint"></a> [global\_cluster\_endpoint](#output\_global\_cluster\_endpoint) | Writer endpoint of the global cluster. Always points to the writer instance of the current primary cluster |
| <a name="output_global_cluster_engine"></a> [global\_cluster\_engine](#output\_global\_cluster\_engine) | The database engine of the global cluster |
| <a name="output_global_cluster_engine_version"></a> [global\_cluster\_engine\_version](#output\_global\_cluster\_engine\_version) | The configured engine version of the global cluster |
| <a name="output_global_cluster_engine_version_actual"></a> [global\_cluster\_engine\_version\_actual](#output\_global\_cluster\_engine\_version\_actual) | The running engine version of the global cluster |
| <a name="output_global_cluster_id"></a> [global\_cluster\_id](#output\_global\_cluster\_id) | The RDS global cluster identifier. Pass it to the `global_cluster_identifier` input of the `terraform-aws-modules/rds-aurora/aws` module |
| <a name="output_global_cluster_members"></a> [global\_cluster\_members](#output\_global\_cluster\_members) | Set of objects containing the ARN (`db_cluster_arn`) and writer flag (`is_writer`) of the global cluster members |
| <a name="output_global_cluster_resource_id"></a> [global\_cluster\_resource\_id](#output\_global\_cluster\_resource\_id) | AWS Region-unique, immutable identifier for the global cluster |
<!-- END_TF_DOCS -->
