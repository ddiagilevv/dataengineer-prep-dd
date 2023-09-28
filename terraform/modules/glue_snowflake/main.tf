resource "aws_glue_job" "parquet_to_snowflake" {
  name          = "parquet-to-snowflake-job"
  role_arn = aws_iam_role.glue_snow.arn
  command {
    name           = "glueetl"
    python_version = "3"
    script_location = "s3://${var.etl_scripts_bucket_name}/to_snow_script.py"
  }

  max_retries = 0
  execution_property {
    max_concurrent_runs = 1
  }

  default_arguments = {
    "--job-language"        = "python"
    "--snowflake-username"  = var.snowflake_username
    "--snowflake-password"  = var.snowflake_password
    "--snowflake-account"   = var.snowflake_account
    "--snowflake-database"  = var.snowflake_database
    "--snowflake-schema"    = var.snowflake_schema
    "--S3_OUTPUT_BUCKET_NAME" = var.s3_output_bucket_name
  }

  timeout = 20 # Время ожидания в минутах (2 дня)
  worker_type = "G.1X" # Вы можете выбрать другой тип воркера в зависимости от ваших потребностей
  number_of_workers = 2 # Количество воркеров, которые будут использованы для выполнения задачи
}

resource "aws_iam_role" "glue_role" {
  name = "glue_execution_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "glue.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
  # Добавьте необходимые политики для доступа к S3 и Snowflake
}



# access
resource "aws_iam_role" "glue_snow" {
  name = "AWSGlueServiceRoleForSnow"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "glue.amazonaws.com"
      },
      Effect = "Allow",
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue-snow-attachment" {
  role       = aws_iam_role.glue_snow.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

#etl_scripts_bucket_name
resource "aws_iam_policy" "glue_s3_access_for_snow" {
  name        = "GlueS3FullAccessForSnow"
  description = "Provides full access to specific S3 bucket."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = "s3:*",
      Resource = [
        "arn:aws:s3:::${var.s3_output_bucket_name}",
        "arn:aws:s3:::${var.s3_output_bucket_name}/*",
        "arn:aws:s3:::${var.etl_scripts_bucket_name}",
        "arn:aws:s3:::${var.etl_scripts_bucket_name}/*"
      ],
      Effect   = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3_access_attachment" {
  role       = aws_iam_role.glue_snow.name
  policy_arn = aws_iam_policy.glue_s3_access_for_snow.arn
}



