#!/bin/sh
docker build -t "754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-apply-for-legal-aid/laa-apply-bot:redis-latest" -f Dockerfile-redis . # build and tag as laa-apply-redis
$(aws --profile laa-apply-bot --region eu-west-2 ecr get-login --no-include-email)
docker push 754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-apply-for-legal-aid/laa-apply-bot:redis-latest
kubectl -n laa-apply-bot-production apply delete deployment redis
kubectl -n laa-apply-bot-production apply -f kubectl_deploy/
