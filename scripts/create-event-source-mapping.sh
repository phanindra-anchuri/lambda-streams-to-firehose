#!/usr/bin/env bash -x

DEFAULT_ENVIRONMENT=qa1
ENVIRONMENT=${1:-$DEFAULT_ENVIRONMENT}
TABLE_NAME=${2}
LAMBDA_FUNCTION_NAME=platform-lambda-ddb-streams-to-firehose

pip install --upgrade --user awscli

streamarn=$(aws dynamodbstreams list-streams --table-name ${TABLE_NAME} | jq '.Streams[0].StreamArn' | tr -d '"')

echo "Stream ARN ${streamarn}"

aws lambda create-event-source-mapping \
--function-name ${LAMBDA_FUNCTION_NAME} \
--starting-position LATEST \
--event-source-arn ${streamarn} \
--enabled