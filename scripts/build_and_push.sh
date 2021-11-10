#!/bin/sh
set -e

echo  'Building docker image...'
out=$(docker build \
        --build-arg BUILD_DATE=$(date +%Y-%m-%dT%H:%M:%S%z) \
        --build-arg BUILD_TAG="app-${GITHUB_SHA}" \
        --build-arg CLUSTER="${CLUSTER_ID}" \
        -t "app-latest"\
        -t "${TAG}" .)
echo "$out"

echo 'Pushing docker image...'
out=$(docker push ${TAG})
echo $out

echo "Applying namespace configuration to ${K8S_NAMESPACE}..."
kubectl -n ${K8S_NAMESPACE} set image -f kubectl_deploy/website-deployment.yaml website=${TAG} --local -o yaml | kubectl -n ${K8S_NAMESPACE} apply -f -
kubectl -n ${K8S_NAMESPACE} set image -f kubectl_deploy/sidekiq-deployment.yaml sidekiq=${TAG} --local -o yaml | kubectl -n ${K8S_NAMESPACE} apply -f -
kubectl -n ${K8S_NAMESPACE} rollout status deployments/website
