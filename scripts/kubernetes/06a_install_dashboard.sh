#!/bin/bash

# from: https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

# deploy the latest configuration of Metrics Server
curl -s https://api.github.com/repos/kubernetes-sigs/metrics-server/releases |
    jq ".[0].assets | map(select(.name == \"components.yaml\")) | .[0].browser_download_url" |
    tr -d '"' |
    xargs kubectl apply -f 

# verify
kubectl get deployment metrics-server -n kube-system

# deploy the latest kubernetes dashboard
LATEST_DASHBOARD_VERSION=`curl -s https://api.github.com/repos/kubernetes/dashboard/releases |
    jq ".[0].name" |
    tr -d '"'`

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/$LATEST_DASHBOARD_VERSION/aio/deploy/recommended.yaml

# create and eks-admin service account
kubectl apply -f ./configs/dashboard/eks-admin-service-account.yaml