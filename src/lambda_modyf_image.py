import boto3
import os
import sys
import uuid
import json
from urllib.parse import unquote_plus
from PIL import Image
import PIL.Image

s3_client = boto3.client('s3')
sqs = boto3.client('sqs')

queue_url = 'https://sqs.eu-central-1.amazonaws.com/890769921003/skuczynska_queue.fifo'


def resize_image(image_path, resized_path):
    with Image.open(image_path) as image:
        image.thumbnail(tuple(x / 2 for x in image.size))
        image.save(resized_path)


def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])
        tmpkey = key.replace('/', '')
        download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)
        upload_path = '/tmp/resized-{}'.format(tmpkey)
        s3_client.download_file(bucket, key, download_path)
        resize_image(download_path, upload_path)
        img_info = image_info(download_path)
        s3_client.upload_file(upload_path, '{}-resized'.format(bucket), key)
        send_message_to_sqs(img_info)


def send_message_to_sqs(image_info):
    response = sqs.send_message(
        QueueUrl=queue_url,
        DelaySeconds=10,
        MessageBody=image_info
    )


def image_info(image_path):
    with Image.open(image_path) as image:
        width, height = image.size
        filename = image.filename
        return json.dumps({'filename': filename, 'width': width, 'height': height})
