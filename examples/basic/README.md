# Aurora Global Cluster example

Creates an Aurora PostgreSQL global cluster with a primary cluster in `eu-west-1` and a secondary cluster in `us-east-1` using [terraform-aws-modules/rds-aurora/aws](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora).

Expects existing VPCs, DB subnet groups and KMS keys in both regions.

```bash
terraform init
terraform plan
terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.61 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aurora_primary"></a> [aurora\_primary](#module\_aurora\_primary) | terraform-aws-modules/rds-aurora/aws | ~> 10.4 |
| <a name="module_aurora_secondary"></a> [aurora\_secondary](#module\_aurora\_secondary) | terraform-aws-modules/rds-aurora/aws | ~> 10.4 |
| <a name="module_global_cluster"></a> [global\_cluster](#module\_global\_cluster) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [random_password.master](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_primary_db_subnet_group_name"></a> [primary\_db\_subnet\_group\_name](#input\_primary\_db\_subnet\_group\_name) | Name of an existing DB subnet group in the primary region | `string` | n/a | yes |
| <a name="input_primary_kms_key_arn"></a> [primary\_kms\_key\_arn](#input\_primary\_kms\_key\_arn) | ARN of the KMS key used to encrypt the primary cluster | `string` | n/a | yes |
| <a name="input_primary_vpc_id"></a> [primary\_vpc\_id](#input\_primary\_vpc\_id) | ID of the VPC in the primary region | `string` | n/a | yes |
| <a name="input_secondary_db_subnet_group_name"></a> [secondary\_db\_subnet\_group\_name](#input\_secondary\_db\_subnet\_group\_name) | Name of an existing DB subnet group in the secondary region | `string` | n/a | yes |
| <a name="input_secondary_kms_key_arn"></a> [secondary\_kms\_key\_arn](#input\_secondary\_kms\_key\_arn) | ARN of the KMS key used to encrypt the secondary cluster | `string` | n/a | yes |
| <a name="input_secondary_vpc_id"></a> [secondary\_vpc\_id](#input\_secondary\_vpc\_id) | ID of the VPC in the secondary region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_global_cluster_endpoint"></a> [global\_cluster\_endpoint](#output\_global\_cluster\_endpoint) | Writer endpoint of the global cluster |
| <a name="output_global_cluster_id"></a> [global\_cluster\_id](#output\_global\_cluster\_id) | The RDS global cluster identifier |
| <a name="output_primary_cluster_endpoint"></a> [primary\_cluster\_endpoint](#output\_primary\_cluster\_endpoint) | Writer endpoint of the primary regional cluster |
| <a name="output_secondary_cluster_reader_endpoint"></a> [secondary\_cluster\_reader\_endpoint](#output\_secondary\_cluster\_reader\_endpoint) | Reader endpoint of the secondary regional cluster |
<!-- END_TF_DOCS -->
