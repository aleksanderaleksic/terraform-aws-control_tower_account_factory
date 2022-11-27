# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
resource "aws_iam_role" "codebuild" {
  name               = local.common_name
  assume_role_policy = file("${path.module}/iam/trust-policies/codebuild.tpl")
}

resource "aws_iam_role" "codebuild_invoker_lambda_role" {
  name               = "codebuild_invoker_role"
  assume_role_policy = file("${path.module}/iam/trust-policies/lambda.tpl")
}

resource "aws_iam_role_policy" "codebuild" {
  role   = aws_iam_role.codebuild.name
  policy = templatefile("${path.module}/iam/role-policies/codebuild.tpl", {
    "data_aws_partition_current_partition"      = data.aws_partition.current.partition
    "aws_region"                                = var.aws_region
    "account_id"                                = local.account_id
    "layer_name"                                = var.lambda_layer_name
    "s3_bucket_name"                            = var.s3_bucket_name
    "cloudwatch_event_name"                     = local.common_name
    "data_aws_kms_alias_aft_key_target_key_arn" = var.aft_kms_key_arn
  })
}

data "aws_iam_policy_document" "statemachine_invoker" {
  statement {
    actions = [
      "states:StartExecution",
      "states:ListExecutions"
    ]
    resources = [
      aws_sfn_state_machine.codebuild_statemachine.arn
    ]
  }
  statement {
    actions = [
      "states:DescribeExecution"
    ]
    resources = [
      "arn:aws:states:${var.aws_region}:${data.aws_caller_identity.session.account_id}:execution:${aws_sfn_state_machine.codebuild_statemachine.name}:*"
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.session.account_id}:*"
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.session.account_id}:log-group:/aws/lambda/${aws_lambda_function.codebuild_statemachine_invoker.function_name}:*"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_invoker_policy" {
  role   = aws_iam_role.codebuild_invoker_lambda_role.name
  policy = data.aws_iam_policy_document.statemachine_invoker.json
}

resource "aws_iam_role_policy_attachment" "codebuild_invoker_VPC_access" {
  role       = aws_iam_role.codebuild_invoker_lambda_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "codebuild_statemachine_trust" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = [
        "states.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "codebuild_statemachine" {
  name               = "aft-lambda-layer-codebuild-statemachine"
  assume_role_policy = data.aws_iam_policy_document.codebuild_statemachine_trust.json
}

data "aws_iam_policy_document" "codebuild_statemachine" {
  statement {
    actions = [
      "codebuild:StartBuild",
      "codebuild:StopBuild",
      "codebuild:BatchGetBuilds",
      "codebuild:BatchGetReports"
    ]
    resources = [
      "arn:aws:codebuild:${var.aws_region}:${data.aws_caller_identity.session.account_id}:project/${aws_codebuild_project.codebuild.name}"
    ]
  }
  statement {
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = [
      "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.session.account_id}:rule/StepFunctionsGetEventForCodeBuildStartBuildRule"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_statemachine_policy" {
  role   = aws_iam_role.codebuild_statemachine.name
  policy = data.aws_iam_policy_document.codebuild_statemachine.json
}
