#!/usr/bin/env bash

DEFAULT_ENVIRONMENT=qa1
ENVIRONMENT=${1:-$DEFAULT_ENVIRONMENT}
LAMBDA_FUNCTION_NAME=platform-lambda-streams-to-firehose-1

eval $(envmgr -e ${ENVIRONMENT})

pip install --upgrade --user awscli

streamarn=$(aws dynamodbstreams list-streams --table-name com.climate.platform.acquisition.uploads | jq '.Streams[0].StreamArn')

echo ${streamarn}

aws lambda remove-permission \
--function-name ${LAMBDA_FUNCTION_NAME} \
--statement-id Sid_${LAMBDA_FUNCTION_NAME}_ddb_backup_lambda

aws lambda add-permission \
--function-name ${LAMBDA_FUNCTION_NAME} \
--statement-id Sid_${LAMBDA_FUNCTION_NAME}_ddb_backup_lambda \
--action lambda:CreateEventSourceMapping \
--principal dynamodb.amazonaws.com \
--source-arn arn:aws:dynamodb:us-east-1:345062758380:table/com.climate.platform.acquisition.uploads/stream/2017-06-07T17:14:31.030

aws lambda create-event-source-mapping \
--function-name ${LAMBDA_FUNCTION_NAME} \
--starting-position LATEST \
--event-source-arn arn:aws:dynamodb:us-east-1:345062758380:table/com.climate.platform.acquisition.uploads/stream/2017-06-07T17:14:31.030 \
--enabled