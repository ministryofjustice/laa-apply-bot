#!/bin/sh
set -e

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update && sudo apt-get install -y awscli docker-ce docker-ce-cli containerd.io ruby-full nodejs

sudo curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.8/bin/linux/amd64/kubectl
sudo chmod +x /usr/bin/kubectl

echo -n ${K8S_CLUSTER_CERT} | base64 -d > ./ca.crt
kubectl config set-cluster ${K8S_CLUSTER_NAME} --certificate-authority=./ca.crt --server=https://api.${K8S_CLUSTER_NAME}
kubectl config set-credentials ${SERVICE_ACCOUNT} --token=${K8S_TOKEN}
kubectl config set-context ${K8S_CLUSTER_NAME} --cluster=${K8S_CLUSTER_NAME} --user=${SERVICE_ACCOUNT} --namespace=${K8S_NAMESPACE}
kubectl config use-context ${K8S_CLUSTER_NAME}

echo "Applying namespace configuration to ${K8S_NAMESPACE}..."
echo "kubectl -n ${K8S_NAMESPACE} apply -f kubectl_deploy/"
