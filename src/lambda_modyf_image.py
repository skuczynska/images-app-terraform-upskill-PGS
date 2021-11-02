import boto3
import uuid
import json
from urllib.parse import unquote_plus
from PIL import Image
import PIL.Image
from botocore.client import Config

s3_client = boto3.client('s3', config=Config(signature_version="s3v4"))
sqs = boto3.client('sqs')


def resize_image(image_path, resized_path):
    with Image.open(image_path) as image:
        image.thumbnail(tuple(x / 2 for x in image.size))
        image.save(resized_path)


def lambda_handler(event, context):
    for record in event['Records']:
        print(event, context)
        bucket = record['s3']['bucket']['name']
        print(bucket)
        key = unquote_plus(record['s3']['object']['key'])
        tmpkey = key.replace('/', '')
        download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)
        upload_path = '/tmp/resized-{}'.format(tmpkey)
        s3_client.download_file(bucket, key, download_path)

        # Resize and upload to bucket
        resize_image(download_path, upload_path)
        s3_client.upload_file(upload_path, '{}-resized'.format(bucket), key)

        # Get image info and send to sqs
        img_info = image_info(download_path)
        send_message_to_sqs(img_info)


def send_message_to_sqs(image_info):
    response = sqs.send_message(
        QueueName="skuczynska_queue.fifo",
        MessageBody=image_info
    )


def image_info(image_path):
    with Image.open(image_path) as image:
        image_info = {
            "Image name": image.filename,
            "Format": image.format,
            "Height": image.height,
            "Width": image.width
        }
        return json.dumps(image_info)
