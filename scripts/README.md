# Deployment steps

# Archive and create lambda function
./create-lambda-function.sh

The lambda function is deployed to qa1 by default.

# Creating the event source mapping 
./create-event-source-mapping.sh

This script creates the mapping between the event source (the dynamodb update streams in this case)
and this lambda function so that the function gets invoked when there source table has updates,
the script also enables the dynamodb update streams on the table in question in case they aren't already enabled.

# Creating the firehose delivery stream
./create-delivery-stream.sh

This script creates a firehose delivey stream with the same name as the table being backed up.
The delivery is to an S3 bucket and Cloudwatch logging is enabled by default to enable us to diagnose
failures with delivery.





