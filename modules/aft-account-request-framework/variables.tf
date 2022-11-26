# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
variable "account_factory_product_name" {
  type = string
}

variable "cloudwatch_log_group_retention" {
  type = string
}

variable "aft_account_provisioning_framework_sfn_name" {
  type = string
}

variable "aft_common_layer_arn" {
  type = string
}

variable "request_framework_archive_path" {
  type = string
}

variable "request_framework_archive_hash" {
  type = string
}

variable "aft_vpc_id" {
  type    = string
  default = null
}

variable "aft_private_subnet_ids" {
  type    = list(string)
  default = []
}
