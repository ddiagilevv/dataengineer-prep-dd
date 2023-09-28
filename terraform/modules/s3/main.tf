resource "random_pet" "bucket_name" {
  length = 3
}

resource "aws_s3_bucket" "s3_input_bucket" {
  bucket = "input-bucket-${random_pet.bucket_name.id}"  # Замените на желаемое имя бакета
  acl    = "private"           # Доступ к бакету ограничен

  # Включение версионирования может быть полезным для учета изменений в бакете
  versioning {
    enabled = true
  }
}
resource "aws_s3_bucket" "s3_output_bucket" {
  bucket = "output-bucket-${random_pet.bucket_name.id}"
  acl    = "private"

  versioning {
    enabled = true
  }
}
#бакет etl (скриптов) в glue
resource "aws_s3_bucket" "etl_scripts_bucket" {
  bucket = "etl-scripts-bucket-${random_pet.bucket_name.id}"
  acl    = "private"
}

#INPUT obj created
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_input_bucket.bucket

  lambda_function {
    lambda_function_arn = var.aws_lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
}
#OUTPUT1 obj created
resource "aws_s3_bucket_notification" "bucket_notification_2" {
  bucket = aws_s3_bucket.s3_output_bucket.bucket

  lambda_function {
    lambda_function_arn = var.trigger_glue_on_s3_event_arn
    events              = ["s3:ObjectCreated:*"]
  }
}
#to snowflake
resource "aws_s3_bucket_notification" "example" {
  bucket = aws_s3_bucket.s3_output_bucket.bucket

  lambda_function {
    lambda_function_arn = var.tosnowflake_arn
    events              = ["s3:ObjectCreated:*"]
  }
}


#для glue to snowflake
resource "aws_s3_object" "etl_script_2" {
  bucket = aws_s3_bucket.etl_scripts_bucket.bucket
  key    = "to_snow_script.py"
  source = "${path.module}/assets/to_snow_script.py"
  etag   = filemd5("${path.module}/assets/to_snow_script.py")
}

#для glue to snowflake
resource "aws_s3_object" "etl_script_1" {
  bucket = aws_s3_bucket.etl_scripts_bucket.bucket
  key    = "script.py"
  source = "${path.module}/assets/script.py"
  etag   = filemd5("${path.module}/assets/script.py")
}