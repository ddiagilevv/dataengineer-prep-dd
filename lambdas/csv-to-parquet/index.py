import os
import boto3
import pandas as pd
from io import BytesIO

def lambda_handler(event, context):
    print(event)
    
    # Получение имени S3 бакета из переменных окружения
    s3_bucket_name = os.environ['S3_BUCKET_NAME']
    s3_output_bucket_name = os.environ['S3_OUTPUT_BUCKET_NAME']

        # Создание клиента S3
    s3_client = boto3.client('s3')

    s3_file_key = event['Records'][0]['s3']['object']['key']

    buffer = BytesIO()

    # Скачивание файла из S3
    s3_client.download_fileobj(s3_bucket_name, s3_file_key, buffer)

    # Чтение файла в DataFrame
    buffer.seek(0)
    df = pd.read_csv(buffer)

    # Преобразование данных в Parquet
    parquet_buffer = BytesIO()
    df.to_parquet(parquet_buffer)

    # Определение имени выходного файла
    output_file_key = os.path.join(os.path.dirname(s3_file_key), 'output', os.path.basename(s3_file_key).replace('.csv', '.parquet'))

    # Сохранение данных обратно в S3
    parquet_buffer.seek(0)
    s3_client.upload_fileobj(parquet_buffer, s3_output_bucket_name, output_file_key)
    print("S3 OUTPUUUT:" + s3_output_bucket_name)

    return {
        'statusCode': 200,
        'body': 'Conversion successful!'
    }
