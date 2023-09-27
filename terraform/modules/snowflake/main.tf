terraform {
  required_providers {
    snowflake = {
      source = "snowflake-labs/snowflake"
    }
  }
}


resource "snowflake_database" "etl_db" {
  name = "NEW_DB_NAME_QWE" # замените на имя вашей базы данных
}

resource "snowflake_schema" "etl_schema" {
  database = snowflake_database.etl_db.name
  name     = "NEW_SCHEMA_NAME_K" # замените на имя вашей схемы
}

#
resource "aws_sqs_queue" "snowflake_queue" {
  name = "snowflake-s3-notifications"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_output_bucket_name

  queue {
    queue_arn     = aws_sqs_queue.snowflake_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".parquet"
  }
}

resource "aws_iam_role" "snowflake_s3_role" {
  name = "SnowflakeS3AccessRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          AWS = "arn:aws:iam::697266982738:user/di7c0000-s"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "snowflake_s3_policy" {
  name = "SnowflakeS3AccessPolicy"
  role = aws_iam_role.snowflake_s3_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_output_bucket_name}",
          "arn:aws:s3:::${var.s3_output_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "snowflake_storage_integration" "s3_integration" {
  name             = "MY_S3_INTEGRATION"
  type             = "EXTERNAL_STAGE"
  storage_provider = "S3"
  enabled          = true

  storage_aws_role_arn = aws_iam_role.snowflake_s3_role.arn

  storage_allowed_locations = [
    "s3://${var.s3_output_bucket_name}/"
  ]
}

resource "snowflake_stage" "etl_stage" {
  database   = snowflake_database.etl_db.name
  schema     = snowflake_schema.etl_schema.name
  name       = "MY_S3_STAGE"
  url        = "s3://${var.s3_output_bucket_name}/etl-output/"
  file_format = "TYPE = 'PARQUET'"
  storage_integration = snowflake_storage_integration.s3_integration.name
}

resource "aws_sqs_queue_policy" "snowflake_sqs_policy" {
  queue_url = aws_sqs_queue.snowflake_queue.id
  
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "snowflakeSQSPolicy",
    Statement = [
      {
        Sid       = "AllowS3BucketNotifications",
        Effect    = "Allow",
        Principal = "*",
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.snowflake_queue.arn,
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${var.s3_output_bucket_name}"
          }
        }
      }
    ]
  })
}
