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


def process_image(image_path, resized_path):
    with Image.open(image_path) as image:
        # resize image
        image.thumbnail(tuple(x / 2 for x in image.size))
        # get image info
        img_info = {
            "Image name": image.filename,
            "Format": image.format,
            "Height": image.height,
            "Width": image.width
        }
        image.save(resized_path)
        # send a file info message to sqs
        sqs = boto3.resource('sqs')
        queue = sqs.get_queue_by_name(QueueName='skuczynska-queue')
        response = queue.send_message(MessageBody=json.dumps(img_info))


def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        tmpkey = key.replace('/', '')
        print(tmpkey)
        download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)
        upload_path = '/tmp/resized-{}'.format(tmpkey)
        s3_client.download_file(bucket, key, download_path)
        process_image(download_path, upload_path)
        # s3_client.upload_file(upload_path, '{}-resized'.format(bucket), key)
        s3_client.upload_file(upload_path, bucket, key)
