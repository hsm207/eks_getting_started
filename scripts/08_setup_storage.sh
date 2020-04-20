#!/bin/bash

# from https://www.kubeflow.org/docs/aws/storage/

# deploy the FSx CSI plugin
cd ~
git clone https://github.com/kubeflow/manifests
cd manifests/aws
kubectl apply -k aws-fsx-csi-driver/base

# apply the settings
cd ~/eks_getting_started
kubectl apply -f ./configs/storage/