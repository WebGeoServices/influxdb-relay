#!/usr/bin/env bash
set -e

BRANCH=${GITHUB_REF##*/}
ECR_REPOSITORY=${1}

if [ -z ${ECR_REPOSITORY} ]; then
    echo "Missing ECR_REPOSITORY parameter."
    echo "usage: deploy.sh <ECR_REPOSITORY>"
    exit 255
fi

if [ "${BRANCH}" ==  "master" ]; then
    eval "$(aws ecr get-login --no-include-email --region us-east-1)"
    docker build -t "${ECR_REPOSITORY}":master .
    docker push "${ECR_REPOSITORY}":master
elif [ "${BRANCH}" ==  "develop" ]; then
    eval "$(aws ecr get-login --no-include-email --region us-east-1)"
    docker build -t "${ECR_REPOSITORY}":develop .
    docker push "${ECR_REPOSITORY}":develop
else
    docker build -t infludb-relay .
fi