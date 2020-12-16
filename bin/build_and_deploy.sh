#!/bin/sh
docker build \
        --build-arg BUILD_DATE=$(date +%Y-%m-%dT%H:%M:%S%z) \
        --build-arg BUILD_TAG="app-${CIRCLE_SHA1}" \
        -t "754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-apply-for-legal-aid/laa-apply-bot:app-latest" .

$(aws --profile laa-apply-bot --region eu-west-2 ecr get-login --no-include-email)
docker push 754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-apply-for-legal-aid/laa-apply-bot:app-latest
# TODO: when I can properly be bothered to insert a build tag this won't be needed
kubectl -n laa-apply-bot-production delete deployments sidekiq website
kubectl -n laa-apply-bot-production apply -f kubectl_deploy/
