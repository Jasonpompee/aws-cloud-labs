import boto3

session = boto3.Session(
    profile_name="jasiensky_admin",
    region_name="us-east-1"
)

logs_client = session.client("logs")

dtable = session.resource("dynamodb")


# logs_response = logs_client.get_log_events(
#     logGroupName="/aws/lambda/weather-notification-v2",
#     logStreamName="2026/09/30/[$LATEST]656a13ff5e524c15b0997923a1faab8b",
#     startFromHead=True,
# )

# for event in logs_response["events"]:
#     print(event["message"])

table = dtable.Table("weather-notification-v2")

response = table.get_item(
    Key={
    "user_id": "2e277920-9a3a-5d1b-97c7-8caaa038448c",
    "record_type": "PROFILE"
}
)

print(response)

