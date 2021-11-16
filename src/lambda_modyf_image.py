import json
import boto3
import os
import sys
import uuid
from urllib.parse import unquote_plus
from PIL import Image
import PIL.Image
from botocore.client import Config

s3_client = boto3.client('s3', config=Config(signature_version="s3v4"))
topic_arn = 'arn:aws:sns:eu-central-1:890769921003:s3-event-notification-topic'

def process_image(image_path, resized_path):
    with Image.open(image_path) as image:
        # Resize image
        # image.thumbnail(tuple(x / 2 for x in image.size))
        size = 128, 128
        image.thumbnail(size)
        # get image info
        img_info = {
            "Image name": image.filename,
            "Format": image.format,
            "Height": image.height,
            "Width": image.width
        }
        image.save(resized_path)

        _send_sqs(img_info)

def _send_sqs(img_info):
    # Send a file info message to sqs
    sqs = boto3.resource('sqs')
    queue = sqs.get_queue_by_name(QueueName='skuczynska-queue')
    response = queue.send_message(MessageBody=json.dumps(img_info))


def publish_sns():
    try:
        sns_client = boto3.client('sns', region_name='eu-central-1')

        created_topic = sns_client.create_topic(Name='sns-topic')
        print(created_topic)

        sns_response = sns_client.publish(Message="Image resized.",
                                          Subject='Image',
                                          TopicArn=topic_arn,
                                          )
        print(sns_response)
    except Exception as e:
        print(e)


def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        tmpkey = key.replace('/', '')
        download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)
        upload_path = '/tmp/resized-{}'.format(key)
        s3_client.download_file(bucket, key, download_path)
        process_image(download_path, upload_path)
        s3_client.upload_file(upload_path, bucket, upload_path)

        publish_sns()
