import boto3
from botocore.client import Config
from botocore.exceptions import ClientError


def lambda_handler(event, context):

    # Generate a presigned URL for the S3 object
    s3_client = boto3.client('s3', config=Config(signature_version='s3v4'))
    bucket_name = 'skuczynska-bucket'
    object_name = 'images'
    expiration = 3600

    try:
        filename = event["filename"]
        response = s3_client.generate_presigned_url('put_object',
                                               Params={'Bucket': bucket_name,
                                                       'Key': f'{object_name}/{filename}'},
                                               ExpiresIn=expiration)


        # The response contains the presigned URL
        return response

    except (ClientError, KeyError) as e:
        return None
