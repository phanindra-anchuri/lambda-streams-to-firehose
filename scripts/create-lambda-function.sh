#!/bin/bash -e

DEFAULT_ENVIRONMENT=qa1
DEFAULT_ROLE_ARN=arn:aws:iam::345062758380:role/platform-ddb-backup-lambda-role

ENVIRONMENT=${1:-$DEFAULT_ENVIRONMENT}
ROLE_ARN=${2:-$DEFAULT_ROLE_ARN}

ARCHIVE_FILE_NAME=lambda-streams-to-firehose.zip
LAMBDA_FUNCTION_NAME=platform-lambda-streams-to-firehose
S3_BUCKET=com.climate.${ENVIRONMENT}.services.versioned
# TODO Change this to platform-ddb-backup when IAM changes take effect.
S3_KEY=platform-api-gateway/${ARCHIVE_FILE_NAME}

function is-default() {
    if [[ -z $2 || "$1" == "$2" ]]
    then
        echo "(default)"
    else
        echo ""
    fi

    return 0
}

echo "usage ./scripts/create-lambda-function.sh [environment] [role-arn]"
echo ""
echo "creating lambda function [${LAMBDA_FUNCTION_NAME}]"
echo "   environment            [${ENVIRONMENT}] $(is-default ${1} ${DEFAULT_ENVIRONMENT})"
echo "   role arn               [${ROLE_ARN}] $(is-default ${2} ${DEFAULT_ROLE_ARN})"

mkdir -p target

echo "creating archive of function"
npm install
rm -f target/${ARCHIVE_FILE_NAME}
zip -x \*node_modules/protobufjs/tests/\* -r target/${ARCHIVE_FILE_NAME} \
../index.js \
 ../router.js \
 ../transformer.js \
 ../constants.js \
 ../lambda.json \
 ../package.json \
 ../node_modules/ \
 ../README.md \
 ../LICENSE NOTICE.txt \
 target/${ARCHIVE_FILE_NAME}

echo "uploading archive to s3"
# TODO Change this to platform-ddb-backup when IAM changes take effect.
aws s3 cp target/${ARCHIVE_FILE_NAME} s3://${S3_BUCKET}/platform-api-gateway/

echo "creating lambda function"
aws lambda create-function \
    --function-name ${LAMBDA_FUNCTION_NAME} \
    --runtime nodejs4.3 \
    --role ${ROLE_ARN} \
    --handler custom-index.handler \
    --code S3Bucket=${S3_BUCKET},S3Key=${S3_KEY} \
    --description "An AWS Lambda function that forwards data from a Kinesis or DynamoDB Update Stream to a Kinesis Firehose Delivery Stream" \
    --timeout 10 \
    --memory-size 128 \
    --publish

echo "SUCCESS!"