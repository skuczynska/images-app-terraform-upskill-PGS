import json
import uuid

import boto3
from botocore.client import Config
from botocore.exceptions import ClientError

# ToDo: hard-coded url, change that to dynamic
queue_url = 'https://sqs.eu-central-1.amazonaws.com/890769921003/skuczynska_queue.fifo'


def lambda_handler(event, context):
    # Generate a presigned URL for the S3 object
    s3_client = boto3.client('s3', config=Config(signature_version='s3v4'))
    bucket_name = 'skuczynska-bucket'
    object_name = 'images'
    expiration = 3600
    try:
        filename = event["filename"]
        mode = event["mode"]
        response = s3_client.generate_presigned_url('put_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': f'{object_name}/{filename}'},
                                                    ExpiresIn=expiration)

        # send_message_to_sqs(queue_url, filename, mode)

        # The response contains the presigned URL
        return response

    except (ClientError, KeyError) as e:
        return None


def send_message_to_sqs(queue_url, filename, mode):
    sqs = boto3.client('sqs')
    response = sqs.send_message(
        QueueUrl=queue_url,
        DelaySeconds=10,
        MessageBody=json.dumps({'filename': filename, 'mode': mode})
    )
