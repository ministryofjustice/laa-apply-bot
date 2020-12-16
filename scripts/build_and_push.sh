#!/bin/sh
set -e

echo 'Run apt-get update'
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update && sudo apt-get install -y awscli docker-ce docker-ce-cli containerd.io ruby-full nodejs jq

sudo curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.8/bin/linux/amd64/kubectl
sudo chmod +x /usr/bin/kubectl

echo -n ${K8S_CLUSTER_CERT} | base64 -d > ./ca.crt
kubectl config set-cluster ${K8S_CLUSTER_NAME} --certificate-authority=./ca.crt --server=https://api.${K8S_CLUSTER_NAME}
kubectl config set-credentials ${SERVICE_ACCOUNT} --token=${K8S_TOKEN}
kubectl config set-context ${K8S_CLUSTER_NAME} --cluster=${K8S_CLUSTER_NAME} --user=${SERVICE_ACCOUNT} --namespace=${K8S_NAMESPACE}
kubectl config use-context ${K8S_CLUSTER_NAME}

export AWS_DEFAULT_REGION=eu-west-2
export AWS_ACCESS_KEY_ID=$(kubectl get secrets -n ${K8S_NAMESPACE} ${ECR_CREDENTIALS_SECRET} -o json | jq -r '.data["access_key_id"]' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl get secrets -n ${K8S_NAMESPACE} ${ECR_CREDENTIALS_SECRET} -o json | jq -r '.data["secret_access_key"]' | base64 --decode)
export ECR_REPO_URL=$(kubectl get secrets -n ${K8S_NAMESPACE} ${ECR_CREDENTIALS_SECRET} -o json | jq -r '.data["repo_url"]' | base64 --decode)
export ECR_HOST=$(echo $ECR_REPO_URL | awk -F/ '{print $1}')
export TAG=${ECR_REPO_URL}:app-${GITHUB_SHA}

echo 'Logging into AWS ECR...'
out=$(aws ecr get-login-password --region eu-west-2 | docker login --username ${ECR_USERNAME} --password-stdin ${ECR_HOST})
echo $out

echo  'Building docker image...'
out=$(docker build \
        --build-arg BUILD_DATE=$(date +%Y-%m-%dT%H:%M:%S%z) \
        --build-arg BUILD_TAG="app-${GITHUB_SHA}" \
        -t ${TAG} .)
echo "$out"

echo 'Pushing docker image...'
out=$(docker push ${TAG})
echo $out

echo "Applying namespace configuration to ${K8S_NAMESPACE}..."
kubectl -n ${K8S_NAMESPACE} set image -f kubectl_deploy/website-deployment.yaml website=${TAG} --local -o yaml | kubectl -n ${K8S_NAMESPACE} apply -f -
kubectl -n ${K8S_NAMESPACE} set image -f kubectl_deploy/sidekiq-deployment.yaml sidekiq=${TAG} --local -o yaml | kubectl -n ${K8S_NAMESPACE} apply -f -
