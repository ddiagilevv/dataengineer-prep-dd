import os
import sys
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.utils import getResolvedOptions
from pyspark.sql.functions import when

# Initialize contexts
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

logger = glueContext.get_logger()

def process_df(df):
    # Drop duplicates
    df = df.dropDuplicates()

    # Replace negative values in 'price' column with 0
    df = df.withColumn('price', when(df['price'] < 0, 0).otherwise(df['price']))

    # Filter out rows where 'product_name' starts with 'Product_'
    df = df.filter(~df['product_name'].startswith('Product_'))

    # Replace NaN values
    df = df.na.fill("Unknown")

    return df

# Reading data from S3 into a DynamicFrame
args = getResolvedOptions(sys.argv, ['S3_OUTPUT_BUCKET_NAME'])
b_name = args['S3_OUTPUT_BUCKET_NAME']

datasource0 = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    format="parquet",
    connection_options={
        "paths": [f"s3://{b_name}/output/"]
    },
    transformation_ctx="datasource0"
)

logger.info("Read data from S3 into DynamicFrame")

# Convert to DataFrame for processing
df = datasource0.toDF()

# Processing
df_processed = process_df(df)
logger.info("Processed DataFrame")
df_processed.show(5)  # This will print the first 5 rows

# Convert back to DynamicFrame
dynamic_frame_write = DynamicFrame.fromDF(df_processed, glueContext, "dynamic_frame_write")

# Writing back to S3
sink = glueContext.write_dynamic_frame.from_options(
    frame=dynamic_frame_write, 
    connection_type="s3", 
    connection_options={"path": f"s3://{b_name}/etl-output/"},
    format="parquet", 
    transformation_ctx="sink"
)

logger.info("Written processed data back to S3")
