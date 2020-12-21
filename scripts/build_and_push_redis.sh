#!/bin/sh
set -e

echo  'Building redis docker image...'
out=$(docker build -t "${ECR_REPO_URL}:redis-latest" .)
echo "$out"

echo 'Pushing redis docker image...'
out=$(docker push "${ECR_REPO_URL}:redis-latest")
echo "$out"

echo "Applying namespace configuration to ${K8S_NAMESPACE}..."
kubectl -n ${K8S_NAMESPACE} apply -f kubectl_deploy/redis-deployment.yaml
kubectl -n ${K8S_NAMESPACE} rollout status deployments/redis
