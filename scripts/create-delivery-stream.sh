#!/usr/bin/env bash

DEFAULT_ENVIRONMENT=qa1
DEFAULT_ROLE_ARN=arn:aws:iam::345062758380:role/platform-firehose-delivery-role
DELIVERY_STREAM_NAME="com.climate.acquisition.uploads"

ENVIRONMENT=${1:-$DEFAULT_ENVIRONMENT}
ROLE_ARN=${2:-$DEFAULT_ROLE_ARN}
S3_BUCKET=com.climate.${ENVIRONMENT}.services

echo -n "Creating Kinesis Firehose Delivery Stream"
deliveryStreamArn=$(aws firehose create-delivery-stream --region us-east-1 --query "DeliveryStreamARN" --output text \
    --delivery-stream-name ${DELIVERY_STREAM_NAME} \
    --s3-destination-configuration "RoleARN=$ROLE_ARN,BucketARN=arn:aws:s3:::$S3_BUCKET,Prefix=ddb-backup/acquisition/uploads/,BufferingHints={SizeInMBs=128,IntervalInSeconds=900},CompressionFormat=GZIP")

echo $deliveryStreamArn