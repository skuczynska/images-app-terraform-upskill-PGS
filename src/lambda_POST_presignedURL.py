import json
import boto3
from botocore.client import Config


def lambda_handler(event, context):
    s3_client = boto3.client('s3', config=Config(signature_version='s3v4'))
    bucket_name = 'skuczynska-upskill'
    object_name = 'images'
    data = json.loads(event["body"])
    filename = data["filename"]
    expiration = 3600
    try:
        response = s3_client.generate_presigned_url('put_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': f'{object_name}/{filename}'},
                                                    ExpiresIn=expiration)
        # The response contains the presigned URL
        return response
    except ClientError as e:
        logging.error(e)
        return None