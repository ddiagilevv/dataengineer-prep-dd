output "aws_lambda_function" {
  value = aws_lambda_function.data_upload_function
}

output "trigger_glue_on_s3_event" {
  value = aws_lambda_function.trigger_glue_on_s3_event
}

output "tosnowflake" {
  value = aws_lambda_function.tosnowflake
}