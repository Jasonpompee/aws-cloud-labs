import boto3


session = boto3.Session(profile_name = "jasiensky_admin")

sts= session.client("sts")


response = sts.assume_role(
    RoleArn="arn:aws:iam::787345512743:role/module77-sts-lab-role",
    RoleSessionName="module77-boto3-test"
)

credentials = (response["Credentials"])

assumed_session = boto3.Session(
    aws_access_key_id=credentials["AccessKeyId"],
    aws_secret_access_key=credentials["SecretAccessKey"],
    aws_session_token=credentials["SessionToken"],
)



client = assumed_session.client("sts")

new_sts = client.get_caller_identity()

print(new_sts)

