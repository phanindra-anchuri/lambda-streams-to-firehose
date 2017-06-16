#!/usr/bin/env bash -x

DEFAULT_ENVIRONMENT=qa1
ENVIRONMENT=${1:-$DEFAULT_ENVIRONMENT}
TABLE_NAME=${2}
LAMBDA_FUNCTION_NAME=platform-lambda-ddb-streams-to-firehose

echo "usage ./scripts/create-event-source-mapping.sh [environment] [table-name]"
echo "   environment            [${ENVIRONMENT}]"
echo "   table            [${TABLE_NAME}]"

eval `envmgr -e ${ENVIRONMENT}`

STREAM_ENABLED=$(aws dynamodb describe-table --table-name ${TABLE_NAME} | jq '.Table.StreamSpecification.StreamEnabled')

if [ "$STREAM_ENABLED" = null ] ; then
    echo "DynamoDB update stream not enabled for table ${TABLE_NAME} in ${ENVIRONMENT}, enabling it now..."
   aws dynamodb update-table \
        --table-name ${TABLE_NAME} \
        --stream-specification "StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES"
fi;

STREAM_ARN=$(aws dynamodb describe-table --table-name ${TABLE_NAME} | jq '.Table.LatestStreamArn'| tr -d '"')

echo ${STREAM_ARN}

echo "Creating event source mapping for table ${TABLE_NAME} and lambda function [${LAMBDA_FUNCTION_NAME}]"
aws lambda create-event-source-mapping \
    --function-name ${LAMBDA_FUNCTION_NAME} \
    --starting-position LATEST \
    --event-source-arn ${STREAM_ARN} \
    --enabled