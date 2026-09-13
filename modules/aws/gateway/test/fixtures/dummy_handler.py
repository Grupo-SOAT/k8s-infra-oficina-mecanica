import json


def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(
            {
                "message": "ok - dummy lambda do teste isolado do gateway",
                "path": event.get("rawPath"),
                "method": event.get("requestContext", {}).get("http", {}).get("method"),
            }
        ),
    }
