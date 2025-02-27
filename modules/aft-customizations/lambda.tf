# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
######## customizations_identify_targets ########


resource "aws_lambda_function" "aft_customizations_identify_targets" {
  filename      = var.customizations_archive_path
  function_name = "aft-customizations-identify-targets"
  description   = "Identifies targets to be customized. Called from aft-trigger-customizations SFN."
  role          = aws_iam_role.aft_customizations_identify_targets_lambda.arn
  handler       = "aft_customizations_identify_targets.lambda_handler"

  source_code_hash = var.customizations_archive_hash
  memory_size      = 1024
  runtime          = "python3.8"
  timeout          = "300"
  layers           = [var.aft_common_layer_arn]


  dynamic "vpc_config" {
    for_each = toset(local.is_vpc_enabled ? ["enabled"] : [])
    content {
      subnet_ids         = var.aft_vpc_private_subnets
      security_group_ids = var.aft_vpc_default_sg
    }
  }
}

resource "aws_cloudwatch_log_group" "aft_customizations_identify_targets" {
  name              = "/aws/lambda/${aws_lambda_function.aft_customizations_identify_targets.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
}


######## customizations_execute_pipeline ########
resource "aws_lambda_function" "aft_customizations_execute_pipeline" {
  filename      = var.customizations_archive_path
  function_name = "aft-customizations-execute-pipeline"
  description   = "Executes the CodePipeline for account baselining. Called from aft-trigger-customizations SFN"
  role          = aws_iam_role.aft_customizations_execute_pipeline_lambda.arn
  handler       = "aft_customizations_execute_pipeline.lambda_handler"

  source_code_hash = var.customizations_archive_hash
  memory_size      = 1024
  runtime          = "python3.8"
  timeout          = "300"
  layers           = [var.aft_common_layer_arn]


  dynamic "vpc_config" {
    for_each = toset(local.is_vpc_enabled ? ["enabled"] : [])
    content {
      subnet_ids         = var.aft_vpc_private_subnets
      security_group_ids = var.aft_vpc_default_sg
    }
  }
}

resource "aws_cloudwatch_log_group" "aft_execute_pipeline" {
  name              = "/aws/lambda/${aws_lambda_function.aft_customizations_execute_pipeline.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
}

######## customizations_get_pipeline_executions ########
resource "aws_lambda_function" "aft_customizations_get_pipeline_executions" {
  filename      = var.customizations_archive_path
  function_name = "aft-customizations-get-pipeline-executions"
  description   = "Gets status of executing pipelines for baselining. Called from aft-trigger-customizations SFN"
  role          = aws_iam_role.aft_customizations_get_pipeline_executions_lambda.arn
  handler       = "aft_customizations_get_pipeline_executions.lambda_handler"

  source_code_hash = var.customizations_archive_hash
  memory_size      = 1024
  runtime          = "python3.8"
  timeout          = "300"
  layers           = [var.aft_common_layer_arn]


  dynamic "vpc_config" {
    for_each = toset(local.is_vpc_enabled ? ["enabled"] : [])
    content {
      subnet_ids         = var.aft_vpc_private_subnets
      security_group_ids = var.aft_vpc_default_sg
    }
  }
}
resource "aws_cloudwatch_log_group" "aft_get_pipeline_executions" {
  name              = "/aws/lambda/${aws_lambda_function.aft_customizations_get_pipeline_executions.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
}

resource "aws_cloudwatch_log_group" "aft_customizations_invoke_account_provisioning" {
  name              = "/aws/lambda/aft-customizations-invoke-account-provisioning"
  retention_in_days = var.cloudwatch_log_group_retention
}
