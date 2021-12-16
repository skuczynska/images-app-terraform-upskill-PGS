import json
import boto3
from botocore.client import Config

def lambda_handler(event, context):
    """"Receive messages from sqs and send data to DynamoDB"""
    client = boto3.client('dynamodb')
    for message in event["Records"]:
        msg = json.loads(message['body'])
        item = {
            "Image name": {
                "S": msg["Image name"],
            },
            "Format": {
                "S": msg["Format"],
            },
            "Height": {
                "N": str(msg["Height"]),
            },
            "Width": {
                "N": str(msg["Width"]),
            },
        }
        response = client.put_item(TableName='skuczynska-images-dynamodb', Item=item)