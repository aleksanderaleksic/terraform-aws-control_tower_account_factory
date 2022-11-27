# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
locals {
  common_name                        = "python-layer-builder-${var.lambda_layer_name}-${random_string.resource_suffix.result}"
  account_id                         = data.aws_caller_identity.session.account_id
  target_id                          = "trigger_build"
  statemachine_invoker_function_name = "aft-lambda-layer-codebuild-statemachine-invoker"
  is_vpc_enabled                     = var.aft_vpc_id != null
  layer_s3_key                       = "layer/${md5(data.local_file.aft_lambda_layer.content)}.zip"
}
