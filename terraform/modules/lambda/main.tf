resource "aws_lambda_layer_version" "code_layer" {
  filename   = "${path.module}/code-layer.zip"
  layer_name = "code-layer"
}

resource "aws_lambda_function" "data_upload_function" {
  function_name = "dataUploadFunction"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_invoke_role.arn
  timeout = 60
  filename           = "${path.module}/code-layer.zip"
  source_code_hash   = filebase64sha256("${path.module}/code-layer.zip")

  environment {
    variables = {
      S3_BUCKET_NAME =  var.s3_input_bucket_name
      S3_OUTPUT_BUCKET_NAME = var.s3_output_bucket_name
    }
  }

  layers = [
    "arn:aws:lambda:eu-north-1:336392948345:layer:AWSSDKPandas-Python38:11"
  ]
}

#glue

resource "aws_lambda_function" "trigger_glue_on_s3_event" {
  function_name = "TriggerGlueOnS3Event"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.lambda_handler"  # Your lambda handler here
  runtime       = "python3.8"
  timeout = 60

  

  filename           = "../lambdas/glue-trigger/code-layer.zip"
  source_code_hash   = filebase64sha256("../lambdas/glue-trigger/code-layer.zip")

  environment {
    variables = {
      GLUE_JOB_NAME = "test-job1"  # Задайте ваше имя Glue Job здесь
    }
  }
}
