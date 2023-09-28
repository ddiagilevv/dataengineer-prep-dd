output "snowflake_database" {
  value = snowflake_database.etl_db.name
}

output "snowflake_schema" {
  value = snowflake_schema.etl_schema.name
}