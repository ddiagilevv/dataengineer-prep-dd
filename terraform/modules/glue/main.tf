resource "aws_glue_catalog_database" "default" {
  name = "my-glue-database"
}

resource "aws_glue_job" "default" {
  name     = "test-job1"
  role_arn = aws_iam_role.glue.arn

  command {
    name            = "glueetl"
    script_location = "s3://${var.etl_scripts_bucket_name}/script.py"
    python_version  = "3"
  }

  default_arguments = {
    "--S3_OUTPUT_BUCKET_NAME" = var.s3_output_bucket_name
    "--job-language" = "python"
  }

  timeout = 60
  glue_version = "4.0"
}

resource "aws_iam_role" "glue" {
  name = "AWSGlueServiceRole"
  
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

resource "aws_iam_role_policy_attachment" "glue" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

#etl_scripts_bucket_name
resource "aws_iam_policy" "glue_s3_access" {
  name        = "GlueS3FullAccess"
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
  role       = aws_iam_role.glue.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}


