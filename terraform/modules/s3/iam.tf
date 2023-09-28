# IAM Role для S3
resource "aws_iam_role" "lambda_s3_role" {
  name = "LambdaS3Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#разрешаем первой лямбде читать и писать в s3
resource "aws_iam_policy" "lambda_s3_access_policy" {
  name        = "LambdaS3AccessPolicy"
  description = "Policy that grants Lambda access to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_input_bucket.arn}", # для чтения из входного бакета
          "arn:aws:s3:::${aws_s3_bucket.s3_input_bucket.arn}/*" # для доступа к объектам внутри входного бакета
        ],
        Effect   = "Allow"
      },
      {
        Action   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_output_bucket.arn}", # для записи в выходной бакет
          "arn:aws:s3:::${aws_s3_bucket.s3_output_bucket.arn}/*" # для доступа к объектам внутри выходного бакета
        ],
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
  role       = aws_iam_role.lambda_s3_role.name
}

#для lambda-glue:
# IAM Role для S3
resource "aws_iam_role" "lambda_glue_role" {
  name = "LambdaGlueRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#разрешаем второй лямбде читать и писать в s3
resource "aws_iam_policy" "lambda_s3_access_policy_glue" {
  name        = "LambdaS3AccessPolicy2"
  description = "Policy that grants Lambda access to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_output_bucket.arn}", # для записи в выходной бакет
          "arn:aws:s3:::${aws_s3_bucket.s3_output_bucket.arn}/*" # для доступа к объектам внутри выходного бакета
        ],
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_glue_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_access_policy_glue.arn
  role       = aws_iam_role.lambda_glue_role.name
}

#для glue-s3
# IAM Role для AWS Glue
resource "aws_iam_role" "etl_role" {
  name = "ETLRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Effect = "Allow",
      },
    ]
  })
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "GlueS3Access"
  role = aws_iam_role.etl_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_output_bucket.arn}", # для записи в выходной бакет
          "arn:aws:s3:::${aws_s3_bucket.s3_output_bucket.arn}/*", # для доступа к объектам внутри выходного бакета
          "arn:aws:s3:::${aws_s3_bucket.etl_scripts_bucket.arn }", # для записи в выходной бакет
          "arn:aws:s3:::${aws_s3_bucket.etl_scripts_bucket.arn}/*" # для доступа к объектам внутри выходного бакета
        ],
      }
    ]
  })
}


resource "aws_lambda_permission" "allow_s3_for_glue" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.trigger_glue_on_s3_event.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_output_bucket.arn
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.aws_lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_input_bucket.arn
}

resource "aws_lambda_permission" "forsnow" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.tosnowflake.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_output_bucket.arn
}

