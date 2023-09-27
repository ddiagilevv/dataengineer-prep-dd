# IAM Role для Lambda
resource "aws_iam_role" "lambda_invoke_role" {
  name = "LambdaInvokeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "LambdaInvokeGlueAndS3Policy"
  description = "Policy that allows Lambda to invoke AWS Glue Jobs, read from input bucket and write to output bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["glue:StartJobRun"], # тут вроде не нужно
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::${var.s3_input_bucket_name}",
          "arn:aws:s3:::${var.s3_input_bucket_name}/*"
        ],
        Effect   = "Allow"
      },
      {
        Action   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"],
        Resource = [
          "arn:aws:s3:::${var.s3_output_bucket_name}",
          "arn:aws:s3:::${var.s3_output_bucket_name}/*"
        ],
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_glue_attach" {
  role       = aws_iam_role.lambda_invoke_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_upload_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_input_bucket}/*"
}

# glue:
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "LambdaExecutionPolicy"
  description = "Allow lambda to run Glue jobs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "glue:StartJobRun"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"],
        Resource = [
          "arn:aws:s3:::${var.s3_output_bucket_name}",
          "arn:aws:s3:::${var.s3_output_bucket_name}/*"
        ],
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_lambda_permission" "allow_second_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_glue_on_s3_event.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_output_bucket}/*"  # Замените на имя вашего бакета
}
