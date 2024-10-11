#!/bin/bash
KIND_VERSION="v0.23.0"

sudo apt install curl
if ! command -v kind &> /dev/null
then
    # For AMD64 / x86_64
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
    # For ARM64
    [ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-arm64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
fi

if ! command -v kubectl &> /dev/null
then
    # For AMD64 / x86_64
    [ $(uname -m) = x86_64 ] && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    # For ARM64
    [ $(uname -m) = aarch64 ] && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
fi

docker network create -d=bridge --subnet=172.40.0.0/24 kind
kind create cluster --name node-js-crash-course-auth --config kind-config.yaml
kubectl config use-context node-js-crash-course-auth
docker build -t node-rediscrashcourse:0.1 -f ../Dockerfile ../
kind load --name node-js-crash-course-auth docker-image node-rediscrashcourse:0.1
kubectl create -f nginx-ingress/namespace.yml
kubectl apply -f nginx-ingress/
kubectl apply -f pv-pvc.yml
kubectl apply -f configmap.yml
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl -n routing-system wait --for=condition=ready=true pod -l app.kubernetes.io/component=controller --timeout=3m
kubectl apply -f ingress.yml
