#!/bin/sh
echo -en $KUBE_CRT > /tmp/kube.crt
kubectl config set-cluster live-cluster --certificate-authority=/tmp/kube.crt --server=$KUBE_API_URL
kubectl config set-credentials apply-user --token=$KUBE_TOKEN_APPLY
kubectl config set-context apply-context --cluster=live-cluster --user=apply-user --namespace=laa-apply-for-legalaid-uat
kubectl config use-context apply-context

echo "Migrate Database"
bundle exec rake db:migrate

bundle exec rackup --host 0.0.0.0 -p "4567"
