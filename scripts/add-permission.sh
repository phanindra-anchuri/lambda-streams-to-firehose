#!/usr/bin/env bash -x

DEFAULT_ENVIRONMENT=qa1
ENVIRONMENT=${1:-$DEFAULT_ENVIRONMENT}
LAMBDA_FUNCTION_NAME=platform-lambda-ddb-streams-to-firehose

pip install --upgrade --user awscli

streamarn=$(aws dynamodbstreams list-streams --table-name com.climate.platform.acquisition.uploads | jq '.Streams[0].StreamArn')

echo ${streamarn}

aws lambda create-event-source-mapping \
--function-name ${LAMBDA_FUNCTION_NAME} \
--starting-position LATEST \
--event-source-arn arn:aws:dynamodb:us-east-1:345062758380:table/com.climate.platform.acquisition.uploads/stream/2017-06-07T17:14:31.030 \
--enabled