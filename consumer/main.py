import json
import boto3
from secret_keys import SecretKeys

secret_keys=SecretKeys()
sqs_client = boto3.client('sqs', region_name=secret_keys.REGION_NAME)

def poll_sqs():
    while True:
        response = sqs_client.receive_message(
            QueueUrl=secret_keys.AWS_SQS_VIDEO_PROCESSING,
            MaxNumberOfMessages=1,
            WaitTimeSeconds=10
        )
        ecs_client = boto3.client('ecs', region_name=secret_keys.REGION_NAME)
        print(response)
        for messages in response.get("Messages",[]):
            message_body =json.loads(messages.get("Body"))

            if (
                "Service" in message_body 
                and "Event" in message_body 
                and message_body.get("Event") == "s3:TestEvent"
            ):
                sqs_client.delete_message(
                    QueueUrl=secret_keys.AWS_SQS_VIDEO_PROCESSING, ReceiptHandle=messages["ReceiptHandle"]
                )
                continue
            if "Records" in message_body:
                s3_record = message_body["Records"][0]["s3"]
                bucket_name = s3_record["bucket"]["name"]
                s3_key = s3_record['object']['key']

                response=ecs_client.run_task(
                    cluster="arn:aws:ecs:us-east-2:237612938672:cluster/Avik-TranscoderCluster",
                    launchType="FARGATE",
                    taskDefinition="arn:aws:ecs:us-east-2:237612938672:task-definition/video-transcoder:4",
                    overrides={
                        "containerOverrides":[
                            {
                                "name":"video-transcoder",
                                "environment":[
                                    {"name":"S3_BUCKET", "value":bucket_name},
                                    {"name":"S3_KEY", "value":s3_key}, 
                                ],
                            }
                        ]
                       
                    },
                    networkConfiguration={
                        "awsvpcConfiguration":{
                            "subnets":[
                                "subnet-08b6947c2661df91f",
                                "subnet-018865791a20e9dd1",
                                "subnet-04b374ed0adc7a5bc",
                            ],
                            "assignPublicIp":"ENABLED",
                            "securityGroups":[
                                "sg-02d50fcab32fee9a5"
                            ]
                        }

                    }

                )
                
                print(response)
                sqs_client.delete_message(
                    QueueUrl=secret_keys.AWS_SQS_VIDEO_PROCESSING, ReceiptHandle=messages["ReceiptHandle"]
                )
                

poll_sqs()