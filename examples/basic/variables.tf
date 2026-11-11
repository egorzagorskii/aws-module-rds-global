variable "primary_vpc_id" {
  description = "ID of the VPC in the primary region"
  type        = string
}

variable "primary_db_subnet_group_name" {
  description = "Name of an existing DB subnet group in the primary region"
  type        = string
}

variable "primary_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt the primary cluster"
  type        = string
}

variable "secondary_vpc_id" {
  description = "ID of the VPC in the secondary region"
  type        = string
}

variable "secondary_db_subnet_group_name" {
  description = "Name of an existing DB subnet group in the secondary region"
  type        = string
}

variable "secondary_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt the secondary cluster"
  type        = string
}
