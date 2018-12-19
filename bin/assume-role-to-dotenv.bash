#!/bin/bash

# The purpose of this script is to assume a role using a profile, 
# grabbing the temporary credentials, then outputing them as 
# environmental variables into a `.env`


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PROFILE=<myprofile>
ROLE_ARN=<account-role-to-assume>
SESSION_NAME=<session-name>
MAX_DURATION=3600
REGION=us-east-1
COMMENT='#AUTO-GENERATED'
DOTENV_FILE=$DIR/../.env

OUTPUT=$(aws --region us-east-1 --profile $PROFILE sts assume-role --duration-seconds $MAX_DURATION --role-arn $ROLE_ARN --role-session-name $SESSION_NAME)

AWS_ACCESS_KEY_ID=$(echo $OUTPUT | jq '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo $OUTPUT | jq '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN==$(echo $OUTPUT | jq '.Credentials.SessionToken')
EXPIRATION=$(echo $OUTPUT | jq '.Credentials.Expiration')

DOTENV=$(sed 's/^.*#AUTO-GENERATED.*//' $DIR/../.env | sed '/^$/d')

APPEND=$(
    echo ""
    echo ""
    echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} $COMMENT"; \
    echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} $COMMENT"; \
    echo "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} $COMMENT"; \
    echo "EXPIRATION=${EXPIRATION} $COMMENT"
);

echo "$DOTENV$APPEND" > $DOTENV_FILE
