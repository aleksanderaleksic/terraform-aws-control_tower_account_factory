# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
resource "aws_lambda_function" "codebuild_statemachine_invoker" {
  filename         = var.builder_archive_path
  function_name    = local.statemachine_invoker_function_name
  description      = "AFT Lambda Layer - CodeBuild Statemachine Invoker"
  role             = aws_iam_role.codebuild_invoker_lambda_role.arn
  handler          = "statemachine_invoker.lambda_handler"
  source_code_hash = var.builder_archive_hash
  memory_size      = 1024
  runtime          = "python3.8"
  timeout          = 900

  dynamic "vpc_config" {
    for_each = toset(local.is_vpc_enabled ? ["enabled"] : [])
    content {
      subnet_ids         = var.aft_vpc_private_subnets
      security_group_ids = var.aft_vpc_default_sg
    }
  }
}

resource "aws_lambda_invocation" "invoke_codebuild_job" {
  function_name = aws_lambda_function.codebuild_statemachine_invoker.function_name

  triggers = {
    aft_lambda_layer_hash = md5(data.local_file.aft_lambda_layer.content_base64)
  }

  depends_on = [
    aws_iam_role_policy.codebuild_invoker_policy
  ]

  input = <<JSON
{
  "stateMachineArn": "${aws_sfn_state_machine.codebuild_statemachine.arn}",
  "aftLambdaLayerHash": "${md5(data.local_file.aft_lambda_layer.content_base64)}"
}
JSON
}

output "lambda_layer_build_status" {
  value = jsondecode(aws_lambda_invocation.invoke_codebuild_job.result)["Status"]
}
