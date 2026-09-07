#!/bin/bash
set -e

echo "Starting WordPress..."

echo "DB Host: $WORDPRESS_DB_HOST"
echo "DB Name: $WORDPRESS_DB_NAME"
echo "DB User: $WORDPRESS_DB_USER"
echo "AWS Region: $AWS_REGION"
echo "SSM Parameter: $SSM_DB_PASSWORD_PARAMETER"

echo "Getting database password from AWS SSM Parameter Store..."

WORDPRESS_DB_PASSWORD=$(aws ssm get-parameter \
    --name "$SSM_DB_PASSWORD_PARAMETER" \
    --with-decryption \
    --region "$AWS_REGION" \
    --query 'Parameter.Value' \
    --output text)

export WORDPRESS_DB_PASSWORD

if [ -z "$WORDPRESS_DB_PASSWORD" ]; then
    echo "ERROR: Failed to retrieve database password from SSM"
    exit 1O
fi

echo "Database password successfully loaded from SSM."

exec docker-entrypoint.sh "$@"
