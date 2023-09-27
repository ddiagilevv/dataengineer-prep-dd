import boto3
import os

def lambda_handler(event, context):
    print(event)
    client = boto3.client('glue')
    glue_job_name = os.environ.get('GLUE_JOB_NAME')  # Получаем имя Glue Job из переменных окружения

    response = client.start_job_run(
        JobName=glue_job_name
    )

    return {
        'statusCode': 200,
        'body': response
    }
