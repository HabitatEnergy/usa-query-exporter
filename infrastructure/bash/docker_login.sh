#!/usr/bin/env bash

set -ex

# ECR login
aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin "$(cat infrastructure/project_config.json | jq -r .aws.account)".dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

# get docker login details
export DOCKERHUB_USERNAME=`aws secretsmanager get-secret-value --secret-id docker_hub_ci_login  --query 'SecretString' --output text --region ${AWS_DEFAULT_REGION} | jq -r ".username"`
export DOCKERHUB_PASSWORD=`aws secretsmanager get-secret-value --secret-id docker_hub_ci_login  --query 'SecretString' --output text --region ${AWS_DEFAULT_REGION} | jq -r ".password"`
# login into docker
echo Logging in to Docker Hub...
echo $DOCKERHUB_PASSWORD | docker login --username $DOCKERHUB_USERNAME --password-stdin