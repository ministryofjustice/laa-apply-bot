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

sudo apt-get update && sudo apt-get install -y awscli docker-ce docker-ce-cli containerd.io

sudo curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.8/bin/linux/amd64/kubectl
sudo chmod +x /usr/bin/kubectl

echo -n ${K8S_CLUSTER_LIVE1_CERT} | base64 -d > ./ca.crt
kubectl config set-cluster ${K8S_CLUSTER_LIVE1_NAME} --certificate-authority=./ca.crt --server=https://${K8S_CLUSTER_LIVE1_NAME}
kubectl config set-credentials ${SERVICE_ACCOUNT} --token=${K8S_LIVE1_TOKEN}
kubectl config set-context ${K8S_CLUSTER_LIVE1_NAME} --cluster=${K8S_CLUSTER_LIVE1_NAME} --user=${SERVICE_ACCOUNT} --namespace=${K8S_NAMESPACE}
kubectl config use-context ${K8S_CLUSTER_LIVE1_NAME}

export AWS_DEFAULT_REGION=eu-west-2
export AWS_ACCESS_KEY_ID=$(kubectl get secrets -n ${K8S_NAMESPACE} ${ECR_CREDENTIALS_SECRET} -o json | jq -r '.data["access_key_id"]' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl get secrets -n ${K8S_NAMESPACE} ${ECR_CREDENTIALS_SECRET} -o json | jq -r '.data["secret_access_key"]' | base64 --decode)
export ECR_REPO_URL=$(kubectl get secrets -n ${K8S_NAMESPACE} ${ECR_CREDENTIALS_SECRET} -o json | jq -r '.data["repo_url"]' | base64 --decode)
export ECR_HOST=$(echo $ECR_REPO_URL | awk -F/ '{print $1}')
export TAG=${ECR_REPO_URL}:app-${GITHUB_SHA}

echo 'Logging into AWS ECR...'
out=$(aws ecr get-login-password --region eu-west-2 | docker login --username ${ECR_USERNAME} --password-stdin ${ECR_HOST})
echo $out

echo input=$1
filename=$(basename "$1")
ext="${filename##*.}"
echo "Running $filename"
case "${ext}"
  in
    rb) out=$(ruby ./scripts/$1); echo "$out";;
    sh) out=$(sh ./scripts/$1); echo "$out";;
esac

