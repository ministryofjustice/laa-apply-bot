#!/bin/sh
set -e

echo  'Building docker image...'
out=$(docker build \
        --build-arg BUILD_DATE=$(date +%Y-%m-%dT%H:%M:%S%z) \
        --build-arg BUILD_TAG="app-${GITHUB_SHA}" \
        -t "app-latest"\
        -t "${TAG}" .)
echo "$out"

echo 'Pushing docker image...'
out=$(docker push ${TAG})
echo $out

echo "Applying namespace configuration to ${K8S_NAMESPACE}..."
# TODO: fix the secret.yaml apply, it currently fails on the github action with this error:
# error parsing kubectl_deploy/secrets.yaml: error converting YAML to JSON: yaml: control characters are not allowed
# it can be applied correctly locally (new secrets are created but fails from the ubuntu github container
# kubectl -n ${K8S_NAMESPACE} apply -f kubectl_deploy/secrets.yaml
kubectl -n ${K8S_NAMESPACE} set image -f kubectl_deploy/website-deployment.yaml website=${TAG} --local -o yaml | kubectl -n ${K8S_NAMESPACE} apply -f -
kubectl -n ${K8S_NAMESPACE} set image -f kubectl_deploy/sidekiq-deployment.yaml sidekiq=${TAG} --local -o yaml | kubectl -n ${K8S_NAMESPACE} apply -f -
kubectl -n ${K8S_NAMESPACE} rollout status deployments/website
