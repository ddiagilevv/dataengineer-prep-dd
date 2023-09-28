import boto3
import json
import snowflake.connector
import os

# Извлекаем параметры из переменных окружения
snowflake_username = os.environ["SNOWFLAKE_USERNAME"]
snowflake_password = os.environ["SNOWFLAKE_PASSWORD"]
snowflake_account = os.environ["SNOWFLAKE_ACCOUNT"]
snowflake_database = os.environ["SNOWFLAKE_DATABASE"]
snowflake_schema = os.environ["SNOWFLAKE_SCHEMA"]
bucket_name = os.environ["S3_OUTPUT_BUCKET_NAME"]

def create_snowflake_table(column_names):
    try:
        con = snowflake.connector.connect(
            user=snowflake_username,
            password=snowflake_password,
            account=snowflake_account,
            database=snowflake_database,
            schema=snowflake_schema
        )
        cursor = con.cursor()
        
        # Здесь вы можете определить формат создания таблицы в Snowflake на основе метаданных Parquet файлов
        # Пример:
        create_table_sql = f"CREATE OR REPLACE TABLE my_table ({', '.join([f'{col} STRING' for col in column_names])})"
        
        cursor.execute(create_table_sql)
        
    except Exception as e:
        print(f"Error creating Snowflake table: {str(e)}")
    finally:
        cursor.close()
        con.close()

def main():
    s3_client = boto3.client('s3')
    
    # Укажите путь к бакету и папке, где будут появляться Parquet файлы
    prefix = 'etl-output/'
    
    try:
        response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
        
        if 'Contents' in response:
            # Получите первый файл Parquet (предполагается, что все файлы имеют одинаковую структуру)
            first_parquet_file = response['Contents'][0]
            
            # Получите метаданные о файле
            metadata_response = s3_client.head_object(Bucket=bucket_name, Key=first_parquet_file['Key'])
            
            # Извлеките имена столбцов из метаданных
            column_names = json.loads(metadata_response['Metadata']['columns'])
            
            # Создайте таблицу в Snowflake на основе имен столбцов
            create_snowflake_table(column_names)
            
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == '__main__':
    main()
