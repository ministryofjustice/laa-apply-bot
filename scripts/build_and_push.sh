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
echo "${GIT_CRYPT_KEY}" | base64 -d | git-crypt unlock -
kubectl -n ${K8S_NAMESPACE} apply -f kubectl_deploy/secrets.yaml
kubectl -n ${K8S_NAMESPACE} set image -f kubectl_deploy/website-deployment.yaml website=${TAG} --local -o yaml | kubectl -n ${K8S_NAMESPACE} apply -f -
kubectl -n ${K8S_NAMESPACE} set image -f kubectl_deploy/sidekiq-deployment.yaml sidekiq=${TAG} --local -o yaml | kubectl -n ${K8S_NAMESPACE} apply -f -
kubectl -n ${K8S_NAMESPACE} rollout status deployments/website
