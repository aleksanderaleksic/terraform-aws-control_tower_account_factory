# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
resource "random_string" "resource_suffix" {
  length  = "8"
  lower   = true
  upper   = false
  special = false
}


resource "aws_lambda_layer_version" "layer_version" {
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lambda_invocation.invoke_codebuild_job]

  layer_name          = "${var.lambda_layer_name}-${replace(var.aft_version, ".", "-")}"
  compatible_runtimes = ["python${var.lambda_layer_python_version}"]
  s3_bucket           = var.s3_bucket_name
  s3_key              = local.layer_s3_key
}
