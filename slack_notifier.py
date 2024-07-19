import json
import os
import urllib3

http = urllib3.PoolManager()

def handler(event, context):
    message = {
        "text": f"Error in Lambda function: {event['detail']['functionArn']}"
    }
    response = http.request(
        "POST",
        os.environ['SLACK_WEBHOOK_URL'],
        body=json.dumps(message),
        headers={'Content-Type': 'application/json'}
    )
    return {
        'statusCode': response.status,
        'body': response.data
    }
