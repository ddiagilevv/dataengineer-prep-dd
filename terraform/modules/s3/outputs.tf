output "s3_input_bucket" {
  value = aws_s3_bucket.s3_input_bucket
}

output "s3_output_bucket" {
  value = aws_s3_bucket.s3_output_bucket
}

output "s3_input_bucket_name" {
  value = aws_s3_bucket.s3_input_bucket.bucket
}

output "s3_output_bucket_name" {
  value = aws_s3_bucket.s3_output_bucket.bucket
}

output "etl_scripts_bucket" {
  value = aws_s3_bucket.etl_scripts_bucket
}

output "etl_scripts_bucket_name" {
  value = aws_s3_bucket.etl_scripts_bucket.bucket
}