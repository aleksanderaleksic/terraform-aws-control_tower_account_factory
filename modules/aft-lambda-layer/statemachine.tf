resource "aws_sfn_state_machine" "codebuild_statemachine" {
  definition = <<JSON
{
  "Comment": "Statemachine starting a codebuild job for building aft lambda layer",
  "StartAt": "CodeBuild StartBuild",
  "States": {
    "CodeBuild StartBuild": {
      "Type": "Task",
      "Resource": "arn:aws:states:::codebuild:startBuild.sync",
      "Parameters": {
        "ProjectName": "${aws_codebuild_project.codebuild.name}"
      },
      "End": true
    }
  }
}
JSON
  name       = "aft-lambda-layer-codebuild-statemachine"
  role_arn   = aws_iam_role.codebuild_statemachine.arn

  depends_on = [
    aws_iam_role_policy.codebuild_statemachine_policy
  ]
}
