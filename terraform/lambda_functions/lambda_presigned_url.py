import boto3
from botocore.client import Config
from botocore.exceptions import ClientError


def lambda_handler(event, context):
    # Generate a presigned URL for the S3 object
    s3_client = boto3.client('s3', config=Config(signature_version='s3v4'))
    bucket_name = 'skuczynska-bucket-resized'
    expiration = 3600

    try:
        object_name = event["filename"]
        response = s3_client.generate_presigned_url(ClientMethod='put_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name
                                                            },
                                                    ExpiresIn=expiration)

        # The response contains the presigned URL
        return response

    except (ClientError, KeyError) as e:
        return None
