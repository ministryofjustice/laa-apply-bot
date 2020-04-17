#!/bin/sh
docker build -t "754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-apply-for-legal-aid/laa-apply-bot:app-latest" .
$(aws --profile laa-apply-bot --region eu-west-2 ecr get-login --no-include-email)
docker push 754256621582.dkr.ecr.eu-west-2.amazonaws.com/laa-apply-for-legal-aid/laa-apply-bot:app-latest
kubectl apply -f kubectl_deploy/
