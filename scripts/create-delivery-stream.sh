#!/usr/bin/env bash

DEFAULT_ENVIRONMENT=qa1
DEFAULT_ROLE_ARN=arn:aws:iam::345062758380:role/platform-firehose-delivery-role

TABLE_NAME=${1}
ENVIRONMENT=${2:-$DEFAULT_ENVIRONMENT}
ROLE_ARN=${3:-$DEFAULT_ROLE_ARN}
S3_BUCKET=com.climate.${ENVIRONMENT}.services
LOG_GROUP="/aws/kinesisfirehose/${TABLE_NAME}"

echo "usage ./scripts/create-delivery-stream.sh [table-name] [environment] [role-arn]"
echo ""
echo "Setting up Kinesis delivery stream for table [${TABLE_NAME}]"
echo "   environment            [${ENVIRONMENT}]"
echo "   role arn               [${ROLE_ARN}]"

echo "Creating Cloudwatch log group "

$(aws logs create-log-group --log-group-name ${LOG_GROUP})

echo -n "Creating Kinesis Firehose Delivery Stream "
deliveryStreamArn=$(aws firehose create-delivery-stream --region us-east-1 --query "DeliveryStreamARN" --output text \
    --delivery-stream-name ${TABLE_NAME} \
    --s3-destination-configuration \
    "RoleARN=$ROLE_ARN, \
    BucketARN=arn:aws:s3:::$S3_BUCKET, \
    Prefix=platform/firehose/ddb-backup/${TABLE_NAME}, \
    BufferingHints={SizeInMBs=128,IntervalInSeconds=900}, \
    CloudWatchLoggingOptions={Enabled=true,LogGroupName=/aws/kinesisfirehose/${TABLE_NAME},LogStreamName=S3Delivery}")

echo $deliveryStreamArn