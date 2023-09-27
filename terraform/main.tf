module "s3" {
  source = "./modules/s3"
  aws_lambda_function_arn = module.lambda.aws_lambda_function.arn
  aws_lambda_function = module.lambda.aws_lambda_function

  trigger_glue_on_s3_event_arn = module.lambda.trigger_glue_on_s3_event.arn
  trigger_glue_on_s3_event = module.lambda.trigger_glue_on_s3_event

}

module "lambda" {
   source = "./modules/lambda"
   s3_input_bucket = module.s3.s3_input_bucket.arn
   s3_output_bucket = module.s3.s3_output_bucket.arn

   s3_input_bucket_name = module.s3.s3_input_bucket_name
   s3_output_bucket_name = module.s3.s3_output_bucket_name
 }


module "glue" {
  source = "./modules/glue"
  etl_scripts_bucket_name = module.s3.etl_scripts_bucket_name
  s3_output_bucket_name = module.s3.s3_output_bucket_name
}

module "snowflake" {
  source = "./modules/snowflake"
  s3_output_bucket_name = module.s3.s3_output_bucket_name
  snowflake_external_id = var.snowflake_external_id
  snowflake_account = var.snowflake_account
}